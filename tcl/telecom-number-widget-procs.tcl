ad_library {

    Telecom_Number input widget and datatype for the OpenACS templating system.

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-09-28
    @cvs-id $Id$

}

namespace eval template {}
namespace eval template::data {}
namespace eval template::data::transform {}
namespace eval template::data::validate {}
namespace eval template::util {}
namespace eval template::util::telecom_number {}
namespace eval template::widget {}

ad_proc -public template::util::telecom_number { command args } {
    Dispatch procedure for the telecom_number object
} {
    eval template::util::telecom_number::$command $args
}

ad_proc -public template::util::telecom_number::create {
    {itu_id {}}
    {national_number {}}
    {area_city_code {}}
    {subscriber_number {}}
    {extension {}}
    {sms_enabled_p {}}
    {best_contact_time {}}
    {location {}}
    {phone_type_id {}}
} {
    return [list $itu_id $national_number $area_city_code $subscriber_number $extension $sms_enabled_p $best_contact_time]
}

ad_proc -public template::util::telecom_number::html_view {
    {itu_id {}}
    {national_number {}}
    {area_city_code {}}
    {subscriber_number {}}
    {extension {}}
    {sms_enabled_p {}}
    {best_contact_time {}}
    {location {}}
    {phone_type_id {}}
} {
    set telecom_number "$national_number $area_city_code-$subscriber_number\x$extension"
    return [ad_text_to_html $telecom_number]
}

ad_proc -public template::util::telecom_number::acquire { type { value "" } } {
    Create a new telecom_number value with some predefined value
    Basically, create and set the telecom_number value
} {
  set telecom_number_list [template::util::telecom_number::create]
  return [template::util::telecom_number::set_property $type $telecom_number_list $value]
}

ad_proc -public template::util::telecom_number::formats {} {
    Returns a list of valid telecom_number formats
} {
# MGEDDERT NOTE: there needs to be a way to implement a way to portray telecom_numberes differently by country
    return { US CA DE }
}

ad_proc -public template::util::telecom_number::itu_codes {} {
    Returns the country list. Cached.
} {
    # This needs to be implemented if needed in the UI
    return [util_memoize [list template::util::telecom_number::country_options_not_cached]]
}

ad_proc -public template::util::telecom_number::itu_codes_not_cached {} {
    Returns the country list.
} {
    # This needs to be implemented if needed in the UI
    return 0
}

ad_proc -public template::data::validate::telecom_number { value_ref message_ref } {

    upvar 2 $message_ref message $value_ref telecom_number_list

    set itu_id                 [template::util::telecom_number::get_property itu_id $telecom_number_list]
    set national_number        [template::util::telecom_number::get_property national_number $telecom_number_list]
    set area_city_code         [template::util::telecom_number::get_property area_city_code $telecom_number_list]
    set subscriber_number      [template::util::telecom_number::get_property subscriber_number $telecom_number_list]
    set extension              [template::util::telecom_number::get_property extension $telecom_number_list]
    set sms_enabled_p          [template::util::telecom_number::get_property sms_enabled_p $telecom_number_list]
    set best_contact_time      [template::util::telecom_number::get_property best_contact_time $telecom_number_list]
    set location               [template::util::telecom_number::get_property location $telecom_number_list]
    set phone_type_id          [template::util::telecom_number::get_property phone_type_id $telecom_number_list]

    set code_one_p [parameter::get -parameter "ForceCountryCodeOneFormatting" -default "0"]    
    if { !code_one_p } {
        # we need to verify that the number is formatted correctly
        # if yes we seperate the number into various elements
    }

#    set fred_p [::string match {^[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]} $subscriber_number]

    ns_log Notice "regnum: $fred_p :$subscriber_number"
#    set fred_p [::string match {[0-9][0-9][0-9]-
#                                [0-9][0-9][0-9]-
#                                [0-9][0-9][0-9][0-9]x
#                                [0-9]+?
#                               } $subscriber_number]
    ns_log Notice "numwithext: $fred_p :$subscriber_number"

    set message_temp ""
    # this is used to make sure there are no invalid characters in the telecom_number
    set telecom_number_temp "$itu_id$national_number$area_city_code$subscriber_number$extension$sms_enabled_p$best_contact_time"
    # we can't use string match since this is containted within the template::data::validate:: namespace
#    if { ![string is integer $telecom_number_temp] } {
#        append message_temp " [_ ams.Telecom_numbers_must_only_contain_numbers_dashes_and_x_es]"
#    } elseif { $national_number == "1" } {
        append message_temp " [_ ams.Country_code_1_telecom_numbers_must_follow_the_AAA-BBB-CCCCxDDDD_format]"
#    } else {
#        append message_temp "int number"
#    }
    ns_log Notice "TCLEVEL: [info level]"
    if { [exists_and_not_null message_temp] } {
        set message [string trim $message_temp]
        return 0
    } else {
        return 1
    }
}
    

ad_proc -public template::data::transform::telecom_number { element_ref } {

    upvar $element_ref element
    set element_id $element(id)

#    set contents [ns_queryget $element_id]
#    set format [ns_queryget $element_id.format]

    set itu_id              [ns_queryget $element_id.itu_id]
    set national_number     [ns_queryget $element_id.national_number]
    set area_city_code      [ns_queryget $element_id.area_city_code]
    set subscriber_number   [ns_queryget $element_id.subscriber_number]
    set extension           [ns_queryget $element_id.extension]
    set sms_enabled_p       [ns_queryget $element_id.sms_enabled_p]
    set best_contact_time   [ns_queryget $element_id.best_contact_time]
    set location            [ns_queryget $element_id.location]
    set phone_type_id       [ns_queryget $element_id.phone_type_id]

    # we need to seperate out the returned value into individual elements
    set number              [ns_queryget $element_id.summary_number]
#    if { [parameter::get -parameter "ForceCountryCodeOneFormatting" -default "0"] } {
        # set need to seperate number into elements - if the formatting is correct
#        set number_main      [lindex [split $number "x"] 0]
#        set number_extension [lindex [split $number "x"] 1]
#        set fred_p [string match {[0-9]{1,}?} $number_extension]
#        set subscriber_number $number
#    } else {
        set subscriber_number $number
#    }

    if { [empty_string_p $subscriber_number] } {
        # We need to return the empty list in order for form builder to think of it 
        # as a non-value in case of a required element.
        return [list]
    } else {
        return [list [list $itu_id $national_number $area_city_code $subscriber_number $extension $sms_enabled_p $best_contact_time $location $phone_type_id]]
    }
}

ad_proc -public template::util::telecom_number::set_property { what telecom_number_list value } {
    Set a property of the telecom_number datatype. 

    @param what One of
    <ul>
    <li>itu_id
    <li>national_number
    <li>area_city_code
    <li>subscriber_number
    <li>extension
    <li>sms_enabled_p
    <li>best_contact_time
    <li>location
    <li>phone_type_id
    </ul>

    @param telecom_number_list the telecom_number list to modify
    @param value the new value

    @return the modified list
} {

    set itu_id                 [template::util::telecom_number::get_property itu_id $telecom_number_list]
    set subscriber_number      [template::util::telecom_number::get_property subscriber_number $telecom_number_list]
    set national_number        [template::util::telecom_number::get_property national_number $telecom_number_list]
    set area_city_code         [template::util::telecom_number::get_property area_city_code $telecom_number_list]
    set extension              [template::util::telecom_number::get_property extension $telecom_number_list]
    set sms_enabled_p          [template::util::telecom_number::get_property sms_enabled_p $telecom_number_list]
    set best_contact_time      [template::util::telecom_number::get_property best_contact_time $telecom_number_list]
    set location               [template::util::telecom_number::get_property location $telecom_number_list]
    set phone_type_id          [template::util::telecom_number::get_property phone_type_id $telecom_number_list]

    switch $what {
        itu_id {
            return [list $value  $national_number $area_city_code $subscriber_number $extension $sms_enabled_p $best_contact_time $location $phone_type_id]
        }
        national_number {
            return [list $itu_id $value           $area_city_code $subscriber_number $extension $sms_enabled_p $best_contact_time $location $phone_type_id]
        }
        area_city_code {
            return [list $itu_id $national_number $value          $subscriber_number $extension $sms_enabled_p $best_contact_time $location $phone_type_id]
        }
        subscriber_number {
            return [list $itu_id $national_number $area_city_code $value             $extension $sms_enabled_p $best_contact_time $location $phone_type_id]
        }
        extension {
            return [list $itu_id $national_number $area_city_code $subscriber_number $value     $sms_enabled_p $best_contact_time $location $phone_type_id]
        }
        sms_enabled_p {
            return [list $itu_id $national_number $area_city_code $subscriber_number $extension $value         $best_contact_time $location $phone_type_id]
        }
        best_contact_time {
            return [list $itu_id $national_number $area_city_code $subscriber_number $extension $sms_enabled_p $value             $location $phone_type_id]
        }
        location {
            return [list $itu_id $national_number $area_city_code $subscriber_number $extension $sms_enabled_p $best_contact_time $value    $phone_type_id]
        }
        phone_type_id {
            return [list $itu_id $national_number $area_city_code $subscriber_number $extension $sms_enabled_p $best_contact_time $location $value]
        }
        default {
            error "Parameter supplied to util::telecom_number::set_property 'what' must be one of: 'itu_id', 'subscriber_number', 'national_number', 'area_city_code', 'extension', 'sms_enabled_p', 'best_contact_time', 'location', 'phone_type_id'. You specified: '$what'."
        }
    }
}

ad_proc -public template::util::telecom_number::get_property { what telecom_number_list } {
    
    Get a property of the telecom_number datatype. Valid properties are: 
    
    @param what the name of the property. Must be one of:
    <ul>
    <li>itu_id (synonyms street_telecom_number, street)
    <li>subscriber_number (synonyms zip_code, zip)
    <li>national_number (synonyms city, town)
    <li>area_city_code (synonyms state, province)
    <li>extension (synonym country)
    <li>addtional_text (this is not implemented in the default US widget)
    <li>best_contact_time (this is not implemented in the default US widget)
    <li>html_view - this returns an nice html formatted view of the telecom_number
    </ul>
    @param telecom_number_list a telecom_number datatype value, usually created with ad_form.
} {

    switch $what {
        itu_id {
            return [lindex $telecom_number_list 0]
        }
        national_number {
            return [lindex $telecom_number_list 1]
        }
        area_city_code {
            return [lindex $telecom_number_list 2]
        }
        subscriber_number {
            return [lindex $telecom_number_list 3]
        }
        extension {
            return [lindex $telecom_number_list 4]
        }
        sms_enabled_p {
            return [lindex $telecom_number_list 5]
        }
        best_contact_time {
            return [lindex $telecom_number_list 6]
        }
        location {
            return [lindex $telecom_number_list 7]
        }
        phone_type_id {
            return [lindex $telecom_number_list 8]
        }
        html_view {
            set itu_id                 [template::util::telecom_number::get_property itu_id $telecom_number_list]
            set subscriber_number      [template::util::telecom_number::get_property subscriber_number $telecom_number_list]
            set national_number        [template::util::telecom_number::get_property national_number $telecom_number_list]
            set area_city_code         [template::util::telecom_number::get_property area_city_code $telecom_number_list]
            set extension              [template::util::telecom_number::get_property extension $telecom_number_list]
            set sms_enabled_p          [template::util::telecom_number::get_property sms_enabled_p $telecom_number_list]
            set best_contact_time      [template::util::telecom_number::get_property best_contact_time $telecom_number_list]
            set location               [template::util::telecom_number::get_property location $telecom_number_list]
            set phone_type_id          [template::util::telecom_number::get_property phone_type_id $telecom_number_list]
            return [template::util::telecom_number::html_view $itu_id $subscriber_number $national_number $area_city_code $extension $sms_enabled_p $best_contact_time $location $phone_type_id]
        }
        default {
            error "Parameter supplied to util::telecom_number::get_property 'what' must be one of: 'itu_id', 'subscriber_number', 'national_number', 'area_city_code', 'extension', 'sms_enabled_p', 'best_contact_time', 'location', 'phone_type_id'. You specified: '$what'."
        }
        
    }
}

ad_proc -public template::widget::telecom_number { element_reference tag_attributes } {
    Implements the telecom_number widget.

} {

  upvar $element_reference element

#  if { [info exists element(html)] } {
#    array set attributes $element(html)
#  }

#  array set attributes $tag_attributes

  if { [info exists element(value)] } {
      set itu_id                 [template::util::telecom_number::get_property itu_id $element(value)]
      set subscriber_number      [template::util::telecom_number::get_property subscriber_number $element(value)]
      set national_number        [template::util::telecom_number::get_property national_number $element(value)]
      set area_city_code         [template::util::telecom_number::get_property area_city_code $element(value)]
      set extension              [template::util::telecom_number::get_property extension $element(value)]
      set sms_enabled_p          [template::util::telecom_number::get_property sms_enabled_p $element(value)]
      set best_contact_time      [template::util::telecom_number::get_property best_contact_time $element(value)]
      set location               [template::util::telecom_number::get_property location $element(value)]
      set phone_type_id          [template::util::telecom_number::get_property phone_type_id $element(value)]
  } else {
      set itu_id                 {}
      set subscriber_number      {}
      set national_number        {}
      set area_city_code         {}
      set extension              {}
      set sms_enabled_p          {}
      set best_contact_time      {}
      set location               {}
      set phone_type_id          {}
  }
  
  set output {}

  if { [string equal $element(mode) "edit"] } {
      
      

      set attributes(id) \"telecom_number__$element(form_id)__$element(id)\"
      set summary_number ""
      if { [exists_and_not_null national_number] } {
          if { $national_number != "1" } {
              append summary_number "011-$national_number"
          }
      }
      if { [exists_and_not_null area_city_code] } {
          if { [exists_and_not_null summary_number] } { append summary_number "-" }
          append summary_number $area_city_code
      }
      if { [exists_and_not_null subscriber_number] } {
          if { [exists_and_not_null summary_number] } { append summary_number "-" }
          append summary_number $subscriber_number
      }
      if { [exists_and_not_null extension] } {
          if { [exists_and_not_null summary_number] } { append summary_number "x" }
          append summary_number $extension
      }
#      set summary_number "$national_number\-$area_city_code\-$subscriber_number\x$extension"
      append output "<input type=\"text\" name=\"$element(id).summary_number\" value=\"[ad_quotehtml $summary_number]\" size=\"20\">"
          
  } else {
      # Display mode
      if { [info exists element(value)] } {
          append output [template::util::telecom_number::get_property html_view $element(value)]
          append output "<input type=\"hidden\" name=\"$element(id).itu_id\" value=\"[ad_quotehtml $itu_id]\">"
          append output "<input type=\"hidden\" name=\"$element(id).national_number\" value=\"[ad_quotehtml $national_number]\">"
          append output "<input type=\"hidden\" name=\"$element(id).area_city_code\" value=\"[ad_quotehtml $area_city_code]\">"
          append output "<input type=\"hidden\" name=\"$element(id).subscriber_number\" value=\"[ad_quotehtml $subscriber_number]\">"
          append output "<input type=\"hidden\" name=\"$element(id).extension\" value=\"[ad_quotehtml $extension]\">"
          append output "<input type=\"hidden\" name=\"$element(id).sms_enabled_p\" value=\"[ad_quotehtml $sms_enabled_p]\">"
          append output "<input type=\"hidden\" name=\"$element(id).best_contact_time\" value=\"[ad_quotehtml $best_contact_time]\">"
          append output "<input type=\"hidden\" name=\"$element(id).location\" value=\"[ad_quotehtml $location]\">"
          append output "<input type=\"hidden\" name=\"$element(id).phone_type_id\" value=\"[ad_quotehtml $phone_type_id]\">"
      }
  }
      
  return $output
}
