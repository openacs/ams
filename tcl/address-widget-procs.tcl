ad_library {

    Address input widget and datatype for the OpenACS templating system.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-09-28
    @cvs-id $Id$

}

namespace eval template {}
namespace eval template::data {}
namespace eval template::data::transform {}
namespace eval template::data::validate {}
namespace eval template::util {}
namespace eval template::util::address {}
namespace eval template::widget {}

ad_proc -public template::util::address { command args } {
    Dispatch procedure for the address object
} {
    eval template::util::address::$command $args
}

ad_proc -public template::util::address::create {
    {delivery_address {}}
    {municipality {}}
    {region {}}
    {postal_code {}}
    {country_code {}}
    {additional_text {}}
    {postal_type {}}
} {
    return [list $delivery_address $municipality $region $postal_code $country_code $additional_text $postal_type]
}

ad_proc -public template::util::address::country {
    {-country_code}
} {
    The returns a i18n'inized pretty country
    name for the provided country_code
} {
    if { [ad_conn isconnected] } {
	# We are in an HTTP connection (request) so use that locale
	set locale [ad_conn locale]
    } else {
	# There is no HTTP connection - resort to system locale
	set locale [lang::system::locale]
    }
    
    set key "ams.country_${country_code}"

    if { [string is true [lang::message::message_exists_p $locale $key]] } {
	set country [lang::message::lookup $locale $key]
    } else {
	# cache the country codes
	template::util::address::country_options_not_cached -locale $locale
	
	if { [string is true [lang::message::message_exists_p $locale $key]] } {
	    set country [lang::message::lookup $locale $key]
	} else {
	    # we get the default en_US key which was created with the
	    # template::util::address::country_options_not_cached proc
	    set country [lang::message::lookup "en_US" $key]
	}
    }
    return $country
}

ad_proc -public template::util::address::town_line {
    {-municipality}
    {-region}
    {-postal_code}
    {-country_code}
} {
    returns a town_line formatted correctly for the country_code
} {
    # Different formats depending on the country_code
    switch $country_code {
	"CA" - "UK" - "US" {
	    # note that two spaces between region and postal_code is intentional
	    set town_line "$municipality, $region  $postal_code"
	}
	"CH" - "DE" {
	    set town_line "$postal_code $municipality"
	}
	default {
	    if { [parameter::get_from_package_key -package_key "ams" -parameter "DefaultAdressLayoutP" -default 1] } {
		set town_line "$municipality $region $postal_code"
	    } else {
		set town_line "$postal_code $municipality $region"
	    }
	}
    }
    return $town_line
}

ad_proc -public template::util::address::html_view {
    {delivery_address {}}
    {municipality {}}
    {region {}}
    {postal_code {}}
    {country_code {}}
    {additional_text {}}
    {postal_type {}}
} {

    if { [lsearch [parameter::get_from_package_key -package_key "ams" -parameter "HideISOCountryCode" -default {}] $country_code] >= 0 } {
	set country ""
    } else {
	set country [template::util::address::country -country_code $country_code]
    }
    set town_line [template::util::address::town_line -municipality $municipality -region $region -postal_code $postal_code -country_code $country_code]

    set address "$delivery_address
$town_line
$country"

    # now we remove the ending country line if no country exists
    set address [string trim $address]
    return [ad_text_to_html $address]
}

ad_proc -public template::util::address::acquire { type { value "" } } {
    Create a new address value with some predefined value
    Basically, create and set the address value
} {
  set address_list [template::util::address::create]
  return [template::util::address::set_property $type $address_list $value]
}

ad_proc -public template::util::address::formats {} {
    Returns a list of valid address formats
} {
    # MGEDDERT NOTE: there needs to be a way to implement a way to portray addresses differently by country
    return { US CA DE }
}

ad_proc -public template::util::address::country_options {} {
    Returns the country list. Cached.
} {
    if { [ad_conn isconnected] } {
        # We are in an HTTP connection (request) so use that locale
        set locale [ad_conn locale]
    } else {
        # There is no HTTP connection - resort to system locale
        set locale [lang::system::locale]
    }
    return [util_memoize [list template::util::address::country_options_not_cached -locale $locale]]
#    return [template::util::address::country_options_not_cached]
}

ad_proc -public template::util::address::country_options_not_cached {
    {-locale "en_US"}
} {
    Returns the country list.
} {
    set country_code_list [db_list get_country_codes {}]
    set return_country_list {}
    set reserved_country_codes [parameter::get_from_package_key -parameter "DefaultISOCountryCode" -package_key "ams" -default ""]

    foreach country $country_code_list {
        if { [lsearch $reserved_country_codes $country] < 0 } {
            lappend return_country_list [list [lang::message::lookup $locale "ref-countries.${country}"] $country]
        }
    }
    set return_country_list [ams::util::sort_list_of_lists -list $return_country_list]
    set country_code {}
    if { [exists_and_not_null reserved_country_codes] } {
        foreach country $reserved_country_codes {
            set country [string toupper $country]
            lappend country_code [list [lang::message::lookup $locale "ref-countries.${country}"] $country]
        }
        set country_code [concat $country_code [list [list "--" ""]] $return_country_list]
    } else {
        set country_code [concat [list [list "" ""]] $return_country_list]
    }
    return $country_code
}

ad_proc -public template::util::address::ca_provinces {
} {
    Returns the list of Canadian (CA country code) provinces.
} {
    # this list of provinces was created on 2006-05-20

    return [list \
		Alberta AB \
		{British Columbia} BC \
		Manitoba MB \
		{New Brunswick} NB \
		{Newfoundland and Labrador} NL \
		{Northwest Territories} NT \
		{Nova Scotia} NS \
		{Nunavut} NU \
		{Ontario} ON \
		{Prince Edward Island} PE \
		Quebec QC \
		Saskatchewan SK \
		Yukon YT \
	       ]


}

ad_proc -public template::data::validate::address { value_ref message_ref } {

    upvar 2 $message_ref message $value_ref address_list

    set delivery_address [template::util::address::get_property delivery_address $address_list]
    set municipality     [template::util::address::get_property municipality $address_list]
    set region           [template::util::address::get_property region $address_list]
    set postal_code      [template::util::address::get_property postal_code $address_list]
    set country_code     [template::util::address::get_property country_code $address_list]
    set additional_text  [template::util::address::get_property additional_text $address_list]
    set postal_type      [template::util::address::get_property postal_type $address_list]

    set message {}
    # this is used to make sure there are no invalid characters in the address
    set address_temp "$delivery_address $municipality $region $postal_code $country_code $additional_text $postal_type"
    if { [::string match "\{" $address_temp] || [::string match "\}" $address_temp] } {
        # for built in display purposes these characters are not allowed, if you need it 
        # to be allowed make SURE that retrieval procs in AMS are also updated
        # to deal with this change
        lappend message "[_ ams.Your_entry_must_not_contain_the_following_characters]: \{ \}."
    }
    if {[::string length $delivery_address] > [parameter::get_from_package_key -parameter "DefaultStreetSize" -package_key "ams" -default "100"] } {
	lappend message "[_ ams.Your_delivery_address_is_too_long]"
    }
    if { [::llength [::split $delivery_address "\n"]] > [parameter::get_from_package_key -parameter "DefaultStreetLines" -package_key "ams" -default "3"] } {
	lappend message "[_ ams.Your_delivery_address_is_too_many_lines]"
    }

    if { $country_code eq "" && $delivery_address ne ""} {
	lappend message "[_ ams.country] is required."
    }

    # Country Specific Validation
    switch $country_code {
        CA {
            # Canada
            if { [exists_and_not_null region] } {
		# the template::data::transform::address proc will
                # convert a fully spelled out province to its correct
                # two character code, so if its not two characters its
		# not a valid province
		set valid_provinces ""
		foreach {full_name province} [template::util::address::ca_provinces] {
		    lappend valid_provinces $province
		}
		if { [lsearch $valid_provinces $region] < 0 } {
		    set valid_provinces [join $valid_provinces ", "]
		    lappend message "\"${region}\" [_ ams.is_not_a_valid_CA_province]."
		}
            } else {
                lappend message "\"[_ ams.region]\" is required."
	    }
            if { [exists_and_not_null postal_code] } {
                if { ![regexp {^([A-Z][0-9][A-Z] [0-9][A-Z][0-9])$} $postal_code] } {
                    lappend message "\"$postal_code\" [_ ams.is_not_a_valid_Canadian_postal_code]."
                }
            } else {
                lappend message "\"[_ ams.postal_code]\" is required."
            }
            if { ![exists_and_not_null municipality] } {
                lappend message "\"[_ ams.municipality]\" is required."
            }
        }
        US {
            # United States
            if { [exists_and_not_null region] } {
                # this should check a cached list
                # this query for some reason cannot go in the address-widget-procs.xql file...
                if { ![db_0or1row validate_state {
                    select 1 from us_states where abbrev = upper(:region) or state_name = upper(:region)
                } ] } {
                    lappend message "\"$region\" [_ ams.is_not_a_valid_US_state]."
                }
            } else {
                lappend message "\"[_ ams.region]\" is required."
            }
            if { [exists_and_not_null postal_code] } {
                if { ![regexp {^([0-9]{5})(-([0-9]{4}))??$} $postal_code] } {
                    lappend message "\"$postal_code\" [_ ams.is_not_a_valid_US_zip_code]."
                }
            } else {
                lappend message "\"[_ ams.postal_code]\" is required."
            }
            if { ![exists_and_not_null municipality] } {
                lappend message "\"[_ ams.municipality]\" is required."
            }
        }
    }
    set message [join $message " "]
    # ns_log notice "MESSAGE: $message"
    if { [exists_and_not_null message] } {
        return 0
    } else {
        return 1
    }
}
    

ad_proc -public template::data::transform::address { element_ref } {

    upvar $element_ref element
    set element_id $element(id)

#    set contents [ns_queryget $element_id]
#    set format [ns_queryget $element_id.format]
    
    set delivery_address [ns_queryget $element_id.delivery_address]
    set municipality     [ns_queryget $element_id.municipality]
    set region           [ns_queryget $element_id.region]
    set postal_code      [ns_queryget $element_id.postal_code]
    set country_code     [ns_queryget $element_id.country_code]
    set additional_text  [ns_queryget $element_id.additional_text]
    set postal_type      [ns_queryget $element_id.postal_type]


#    if { [empty_string_p $country_code]} {
#        # We need to return the empty list in order for form builder to think of it 
#        # as a non-value in case of a required element.
#        return [list]
#    } else {
        if { $country_code == "US" } {
            # since we have reference data installed we can automatically get a standardized
            # state code
	    if { $region ne "" } {
                if { [db_0or1row get_standardized_region { select abbrev from us_states where abbrev = upper(:region) or state_name = upper(:region) }] } {
		    set region $abbrev
		}
	    }
            # since we have reference data installed we can automatically fill in these values for
            # US States and Cities
            if { [regexp {^([0-9]{5})(-([0-9]{4}))??$} $postal_code] } {
                regexp {^([0-9]{5})(-([0-9]{4}))??$} $postal_code match zipcode
                if { ![exists_and_not_null region] } {
                    set region [db_string get_region {
                        select abbrev
                          from us_states
                         where us_states.fips_state_code = ( select us_zipcodes.fips_state_code
                                                               from us_zipcodes
                                                              where zipcode = :zipcode )
                    } -default {}]
                }
                if { ![exists_and_not_null municipality] } {
                    set municipality [db_string get_municipality {
                        select name
                          from us_zipcodes
                         where zipcode = :zipcode} -default {}]
                }
            }
        }
        if { $country_code == "CA" } {
	    if { [string length $region] ne "2" } {
		array set ca_provinces [string toupper [template::util::address::ca_provinces]]
		if { [info exists ca_provinces([string toupper $region])] } {
		    set region $ca_provinces([string toupper $region])
		}
	    } else {
		set region [string toupper $region]
	    }
	    if { [string length $postal_code] == "6" } {
		set postal_list [split $postal_code {}]
		set postal_code_temp [string toupper "[join [lrange $postal_list 0 2] {}] [join [lrange $postal_list 3 5] {}]"]
		if { [regexp {^([A-Z][0-9][A-Z] [0-9][A-Z][0-9])$} $postal_code_temp] } {
		    set postal_code $postal_code_temp
		}
	    }
        }
        if { $country_code == "US" || $country_code == "CA" } {
            # make the city pretty
            set municipality_temp {}
            foreach word $municipality {
                # I am sure there are more then "Mc" words when they come up add them here
                if { [regexp {^MC([a-zA-Z]+?)} [string toupper $word]] } {
                    lappend municipality_temp [join "Mc[string toupper [lindex [split $word {}] 2]][string tolower [lrange [split $word {}] 3 [llength [split $word {}]]]]" {}]
                } else {
                    lappend municipality_temp [string totitle $word]
                }
            }
            set municipality [join $municipality_temp " "]
                     
        }


        set postal_code [string toupper $postal_code]

        return [list [list $delivery_address $municipality $region $postal_code $country_code $additional_text $postal_type]]
#    }
}

ad_proc -public template::util::address::set_property { what address_list value } {
    Set a property of the address datatype. 

    @param what One of
    <ul>
    <li>delivery_address (synonyms street_address, street)
    <li>postal_code (synonyms zip_code, zip)
    <li>municipality (synonyms city, town)
    <li>region (synonyms state, province)
    <li>country_code (synonym country)
    <li>addtional_text (this is not implemented in the default US widget)
    <li>postal_type (this is not implemented in the default US widget)
    </ul>

    @param address_list the address list to modify
    @param value the new value

    @return the modified list
} {

    set delivery_address [template::util::address::get_property delivery_address $address_list]
    set postal_code      [template::util::address::get_property postal_code $address_list]
    set municipality     [template::util::address::get_property municipality $address_list]
    set region           [template::util::address::get_property region $address_list]
    set country_code     [template::util::address::get_property country_code $address_list]
    set additional_text  [template::util::address::get_property additional_text $address_list]
    set postal_type      [template::util::address::get_property postal_type $address_list]

    switch $what {
        delivery_address - street_address - street {
            return [list $value            $municipality $region $postal_code $country_code $additional_text $postal_type]
        }
        municipality - city - town {
            return [list $delivery_address $value        $region $postal_code $country_code $additional_text $postal_type]
        }
        region - state - province {
            return [list $delivery_address $municipality $value  $postal_code $country_code $additional_text $postal_type]
        }
        postal_code - zip_code - zip {
            return [list $delivery_address $municipality $region $value       $country_code $additional_text $postal_type]
        }
        country_code - country {
            return [list $delivery_address $municipality $region $postal_code $value        $additional_text $postal_type]
        }
        additional_text {
            return [list $delivery_address $municipality $region $postal_code $country_code $value           $postal_type]
        }
        postal_type {
            return [list $delivery_address $municipality $region $postal_code $country_code $additional_text $value      ]
        }
        default {
            error "Parameter supplied to util::address::set_property 'what' must be one of: 'delivery_address', 'postal_code', 'municipality', 'region', 'country_code', 'additional_text', 'postal_type'. You specified: '$what'."
        }
    }
}

ad_proc -public template::util::address::get_property { what address_list } {
    
    Get a property of the address datatype. Valid properties are: 
    
    @param what the name of the property. Must be one of:
    <ul>
    <li>delivery_address (synonyms street_address, street)
    <li>postal_code (synonyms zip_code, zip)
    <li>municipality (synonyms city, town)
    <li>region (synonyms state, province)
    <li>country_code (synonym country)
    <li>addtional_text (this is not implemented in the default US widget)
    <li>postal_type (this is not implemented in the default US widget)
    <li>html_view - this returns an nice html formatted view of the address
    </ul>
    @param address_list a address datatype value, usually created with ad_form.
} {

    switch $what {
        delivery_address - street_address - street {
            return [lindex $address_list 0]
        }
        municipality - city - town {
            return [lindex $address_list 1]
        }
        region - state - province {
            return [lindex $address_list 2]
        }
        postal_code - zip_code - zip {
            return [lindex $address_list 3]
        }
        country_code - country {
            return [lindex $address_list 4]
        }
        additional_text {
            return [lindex $address_list 5]
        }
        postal_type {
            return [lindex $address_list 6]
        }
        html_view {
            set delivery_address [template::util::address::get_property delivery_address $address_list]
            set postal_code      [template::util::address::get_property postal_code $address_list]
            set municipality     [template::util::address::get_property municipality $address_list]
            set region           [template::util::address::get_property region $address_list]
            set country_code     [template::util::address::get_property country_code $address_list]
            set additional_text  [template::util::address::get_property additional_text $address_list]
            set postal_type      [template::util::address::get_property postal_type $address_list]
            return [template::util::address::html_view $delivery_address $municipality $region $postal_code $country_code $additional_text $postal_type]
        }
        default {
            error "Parameter supplied to template::util::address::get_property 'what' must be one of: 'delivery_address', 'postal_code', 'municipality', 'region', 'country_code', 'additional_text', 'postal_type'. You specified: '$what'."
            ns_log "AMS Address Widget Error: on page [ad_conn url] template::util::address::get_property asked for $what"
            return ""
        }
        
    }
}

ad_proc -public template::widget::address { element_reference tag_attributes } {
    Implements the address widget.

} {

  upvar $element_reference element

#  if { [info exists element(html)] } {
#    array set attributes $element(html)
#  }

#  array set attributes $tag_attributes

  if { [info exists element(value)] } {
      set delivery_address [template::util::address::get_property delivery_address $element(value)]
      set postal_code      [template::util::address::get_property postal_code $element(value)]
      set municipality     [template::util::address::get_property municipality $element(value)]
      set region           [template::util::address::get_property region $element(value)]
      set country_code     [template::util::address::get_property country_code $element(value)]
      set additional_text  [template::util::address::get_property additional_text $element(value)]
      set postal_type      [template::util::address::get_property postal_type $element(value)]
  } else {
      set delivery_address {}
      set postal_code      {}
      set municipality     {}
      set region           {}
      set country_code     [lindex [parameter::get_from_package_key -parameter "DefaultISOCountryCode" -package_key "ams" -default ""] 0]
      set additional_text  {}
      set postal_type      {}
  }
  
  set output {}

  if { [string equal $element(mode) "edit"] } {
      

#      set attributes(id) "address__$element(form_id)__$element(id)"
      set attributes(class) "address-widget-country-code"

      append output "
<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" class=\"address-widget\">
  <tr>
    <td colspan=\"3\"><textarea name=\"$element(id).delivery_address\" rows=\"2\" cols=\"50\" wrap=\"virtual\" maxlength=\"100\" class=\"address-widget-delivery-address\" >[ad_quotehtml $delivery_address]</textarea></td>
  </tr>
  <tr>
    <td colspan=\"3\"><small>[_ ams.delivery_address]</small><br></td>
  </tr>
  <tr>
"
      if  { [parameter::get_from_package_key -package_key "ams" -parameter "DefaultAdressLayoutP" -default 1] } {
	  append output "
            <td><input type=\"text\" name=\"$element(id).municipality\" value=\"[ad_quotehtml $municipality]\" size=\"20\" class=\"address-widget-municipality\" ></td>
            <td><input type=\"text\" name=\"$element(id).region\" value=\"[ad_quotehtml $region]\" size=\"10\" class=\"address-widget-region\" ></td>
            <td><input type=\"text\" name=\"$element(id).postal_code\" value=\"[ad_quotehtml $postal_code]\" size=\"7\" class=\"address-widget-postal_code\" ></td>
        </tr>
        <tr>
           <td align=\"left\"><small>[_ ams.municipality]</small></td>
           <td align=\"left\"><small>[_ ams.region]</small></td>
           <td align=\"left\"><small>[_ ams.postal_code]</small></td>
        </tr>"
      } else {
	  append output "
            <td><input type=\"text\" name=\"$element(id).postal_code\" value=\"[ad_quotehtml $postal_code]\" size=\"7\" maxlength=\"38\" class=\"address-widget-postal_code\" ></td>
            <td><input type=\"text\" name=\"$element(id).municipality\" value=\"[ad_quotehtml $municipality]\" size=\"20\" maxlength=\"38\" class=\"address-widget-municipality\" ></td>
            <td><input type=\"text\" name=\"$element(id).region\" value=\"[ad_quotehtml $region]\" size=\"10\" maxlength=\"38\" class=\"address-widget-region\" ></td>
        </tr>
        <tr>
           <td align=\"left\"><small>[_ ams.postal_code]</small></td>
           <td align=\"left\"><small>[_ ams.municipality]</small></td>
           <td align=\"left\"><small>[_ ams.region]</small></td>
        </tr>"
      }
      append output "
  <tr>
    <td colspan=\"3\">[menu $element(id).country_code [template::util::address::country_options] $country_code attributes]</td>
  </tr>
  <tr>
    <td colspan=\"3\"><small>[_ ams.country]</small></td>
  </tr>
</table>
"
          
  } else {
      # Display mode
      if { [info exists element(value)] } {
          append output [template::util::address::get_property html_view $element(value)]
          append output "<input type=\"hidden\" name=\"$element(id).delivery_address\" value=\"[ad_quotehtml $delivery_address]\">"
          append output "<input type=\"hidden\" name=\"$element(id).municipality\" value=\"[ad_quotehtml $municipality]\">"
          append output "<input type=\"hidden\" name=\"$element(id).region\" value=\"[ad_quotehtml $region]\">"
          append output "<input type=\"hidden\" name=\"$element(id).postal_code\" value=\"[ad_quotehtml $postal_code]\">"
          append output "<input type=\"hidden\" name=\"$element(id).country_code\" value=\"[ad_quotehtml $country_code]\">"
          append output "<input type=\"hidden\" name=\"$element(id).additional_text\" value=\"[ad_quotehtml $additional_text]\">"
          append output "<input type=\"hidden\" name=\"$element(id).postal_type\" value=\"[ad_quotehtml $postal_type]\">"
      }
  }
      
  return $output
}
