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

ad_proc -public template::util::address::html_view {
    {delivery_address {}}
    {municipality {}}
    {region {}}
    {postal_code {}}
    {country_code {}}
    {additional_text {}}
    {postal_type {}}
} {
    # MGEDDERT TODO, convert country code to country name via cached proc
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

    set address "$delivery_address
$municipality, $region  $postal_code
$country"
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
}

ad_proc -public template::util::address::country_options_not_cached {
    {-locale "en_US"}
} {
    Returns the country list.
} {
    set country_list [db_list_of_lists get_countries {}]
    set return_country_list [list]
    foreach country $country_list {
        set this_locale $locale
        set country_name_db [lindex $country 0]
        set country_code_db [lindex $country 1]
        set package_key "ams"
        set message_key "country_${country_code_db}"
        set key "${package_key}.${message_key}"
        if { [string is false [lang::message::message_exists_p $locale $key]] } {
            if { [string is false [lang::message::message_exists_p "en_US" $key]] } {
                lang::message::register $locale $package_key $message_key $country_name_db
            } else {
                set this_locale "en_US"
            }
        }
        # mgeddert customization for mbbs
        if { [lsearch [list US CA] $country_code_db] < 0 } {
            # the reason not to use the "list" command here is because a curly bracket
            # needs to be used in the list for countries with a single word name
            # so that alphabetizing (via lsort) works later on in this proc
            lappend return_country_list "{[lang::message::lookup $this_locale $key]} {$country_code_db}"
        }
    }
    set country_code [list]
    lappend country_code [list "United States" US]
    lappend country_code [list "Canada" CA]
    lappend country_code [list "--" ""]
    append country_code " [lsort $return_country_list]"
    return $country_code
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

    set message ""
    # this is used to make sure there are no invalid characters in the address
    set address_temp "$delivery_address $municipality $region $postal_code $country_code $additional_text $postal_type"
    if { [::string match "\{" $address_temp] || [::string match "\}" $address_temp] } {
        # for built in display purposes these characters are not allowed, if you need it 
        # to be allowed make SURE that retrieval procs in AMS are also updated
        # to deal with this change
        if { [exists_and_not_null message_temp] } { append message " " }
        append message "[_ ams.Your_entry_must_not_contain_the_following_characters]: \{ \}."
    }
    if { $country_code == "US" } {
        # this should check a cached list
        # this proc cannot for some reason go in the postgresql file...
        if { ![db_0or1row validate_state {
        select 1 from us_states where abbrev = upper(:region) or state_name = upper(:region)
} ] } {
            if { [exists_and_not_null message_temp] } { append message " " }
            append message "\"$region\" [_ ams.is_not_a_valid_US_state]."
        }
    }
    if { [exists_and_not_null message_temp] } {
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



    if { [empty_string_p $delivery_address] } {
        # We need to return the empty list in order for form builder to think of it 
        # as a non-value in case of a required element.
        return [list]
    } else {
        return [list [list $delivery_address $municipality $region $postal_code $country_code $additional_text $postal_type]]
    }
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
      set country_code     [parameter::get -parameter "DefaultISOCountryCode" -default "US"]
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
    <td colspan=\"3\"><textarea name=\"$element(id).delivery_address\" rows=\"2\" cols=\"50\" wrap=\"virtual\" class=\"address-widget-delivery-address\" >[ad_quotehtml $delivery_address]</textarea></td>
  </tr>
  <tr>
    <td colspan=\"3\"><small>[_ ams.delivery_address]</small><br></td>
  </tr>
  <tr>
    <td><input type=\"text\" name=\"$element(id).municipality\" value=\"[ad_quotehtml $municipality]\" size=\"20\" class=\"address-widget-municipality\" ></td>
    <td><input type=\"text\" name=\"$element(id).region\" value=\"[ad_quotehtml $region]\" size=\"10\" class=\"address-widget-region\" ></td>
    <td><input type=\"text\" name=\"$element(id).postal_code\" value=\"[ad_quotehtml $postal_code]\" size=\"7\" class=\"address-widget-postal_code\" ></td>
  </tr>
  <tr>
    <td align=\"left\"><small>[_ ams.municipality]</small></td>
    <td align=\"center\"><small>[_ ams.region]</small></td>
    <td align=\"right\"><small>[_ ams.postal_code]</small></td>
  </tr>
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
