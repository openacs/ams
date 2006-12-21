ad_library {

    Mobile_Number input widget and utilities procs for the OpenACS templating system.

    @author Al-Faisal El-Dajani
    @creation-date 2006-02-02
}

namespace eval template {}
namespace eval template::data {}
namespace eval template::data::transform {}
namespace eval template::data::validate {}
namespace eval template::util {}
namespace eval template::util::mobile_number {}
namespace eval template::util::aim {}
namespace eval template::util::skype {}
namespace eval template::widget {}

ad_proc -public template::util::mobile_number { command args } {
    Dispatch procedure for the mobile_number object
} {
    eval template::util::mobile_number::$command $args
}

ad_proc -public template::util::mobile_number::create {
    {itu_id {}}
    {national_number {}}
    {subscriber_number {}}
    {best_contact_time {}}
} {
    return [list $itu_id $national_number $subscriber_number $best_contact_time]
}

ad_proc -public template::util::mobile_number::html_view {
    {itu_id {}}
    {national_number {}}
    {subscriber_number {}}
    {best_contact_time {}}
} {
    set mobile_number ""
    if { [parameter::get_from_package_key -parameter "ForceCountryCodeOneFormatting" -package_key "ams" -default "0"] } {
        if { $national_number != "1" } {
            set mobile_number "[_ ams.international_dial_code]${national_number}-"
        }
    } else {
        set mobile_number ${national_number}
        if { [exists_and_not_null mobile_number] } { append mobile_number "-" }
    }
    append mobile_number "$subscriber_number"
    set mobile_url [parameter::get_from_package_key -parameter "MobileURL" -package_key "ams" -default ""]
    if {[empty_string_p $mobile_url]} {
	return $mobile_number
    } else {
	set recipient_mobile_phone_number $mobile_number
	set url [export_vars -base $mobile_url {recipient_mobile_phone_number}]
	return "<a href=\"$url\">$mobile_number</a>"
    }
}

ad_proc -public template::util::mobile_number::acquire { type { value "" } } {
    Create a new mobile_number value with some predefined value
    Basically, create and set the mobile_number value
} {
  set mobile_number_list [template::util::mobile_number::create]
  return [template::util::mobile_number::set_property $type $mobile_number_list $value]
}

ad_proc -public template::util::mobile_number::itu_codes {} {
    Returns the country list. Cached.
} {
    # This needs to be implemented if needed in the UI
    return [util_memoize [list template::util::mobile_number::country_options_not_cached]]
}

ad_proc -public template::util::mobile_number::itu_codes_not_cached {} {
    Returns the country list.
} {
    # This needs to be implemented if needed in the UI
    return 0
}

ad_proc -public template::data::validate::mobile_number { value_ref message_ref } {

    upvar 2 $message_ref message $value_ref mobile_number_list

    set itu_id                 [template::util::mobile_number::get_property itu_id $mobile_number_list]
    set national_number        [template::util::mobile_number::get_property national_number $mobile_number_list]
    set subscriber_number      [template::util::mobile_number::get_property subscriber_number $mobile_number_list]
    set best_contact_time      [template::util::mobile_number::get_property best_contact_time $mobile_number_list]
    
    if { ![parameter::get_from_package_key -parameter "ForceCountryCodeOneFormatting" -package_key "ams" -default "0"] } {
        # the number is not required to be formatted in a country code one friendly way

        # we need to verify that the number does not contain invalid characters
        set mobile_number_temp "$itu_id$national_number$subscriber_number$best_contact_time"
        regsub -all " " $mobile_number_temp "" mobile_number_temp
        if { ![regexp {^([0-9]|x|-|\+|\)|\(){1,}$} $mobile_number_temp match mobile_number_temp] } {
	    set message [_ ams.lt_Mobile_numbers_must_only_contain]
        }
    } else {
        # we have a number in country code one that must follow certain formatting guidelines
        # the template::data::transform::mobile_number proc will have already seperated 
        # the entry from a single entry field into the appropriate values if its formatted 
        # correctly. This means that if values exist for national_number
        # the number was formatted correctly. If not we need to reply with a message that lets
        # users know how they are supposed to format numbers.
        
        if { ![exists_and_not_null national_number] } {
            set message [_ ams.lt_Mobile_numbers_in_country_code]
        }
    }

    if { [exists_and_not_null message] } {
        return 0
    } else {
        return 1
    }
}
    
ad_proc -public template::data::transform::mobile_number { element_ref } {

    upvar $element_ref element
    set element_id $element(id)

    # if in the future somebody wants a widget with many individual fields this will be necessary
    set itu_id              [ns_queryget $element_id.itu_id]
    set national_number     [ns_queryget $element_id.national_number]
    set subscriber_number   [ns_queryget $element_id.subscriber_number]
    set best_contact_time   [ns_queryget $element_id.best_contact_time]

    # we need to seperate out the returned value into individual elements for a single box entry widget
    set number              [string trim [ns_queryget $element_id.summary_number]]

    if { ![parameter::get_from_package_key -parameter "ForceCountryCodeOneFormatting" -package_key "ams" -default "0"] } {
        # we need to verify that the number is formatted correctly
        # if yes we seperate the number into various elements
        set subscriber_number $number
    } else {
        # we need to verify that the number is a valid format. 
        
        # if the number is formatted correctly these regexp statements will automatically
        # set the appropriate values for this string
        set in_country_p [regexp {^(\d{3})-(\d{3}-\d{4})(x\d{1,})??$} $number match area_city_code subscriber_number extension]
        if { [string is true $in_country_p] } {
            set national_number "1"
         }
        
        set out_of_country_p [regexp {^011-(\d{1,})-(\d{1,})-(\d[-|\d]{1,}\d)(x\d{1,})??$} $number match national_number area_city_code subscriber_number extension]

        if { [string is false $in_country_p] && [string is false $out_of_country_p] } {
            # The number is not in a valid format we pass on the 
            # subscriber number for validation errors.
            set subscriber_number $number
        }
    }
    if { [empty_string_p $subscriber_number] } {
        # We need to return the empty list in order for form builder to think of it 
        # as a non-value in case of a required element.
        return [list]
    } else {
        return [list [list $itu_id $national_number $subscriber_number $best_contact_time]]
    }
}

ad_proc -public template::util::mobile_number::set_property { what mobile_number_list value } {
    Set a property of the mobile_number datatype. 

    @param what One of
    <ul>
    <li>itu_id
    <li>national_number
    <li>subscriber_number
    <li>best_contact_time
    </ul>

    @param mobile_number_list the mobile_number list to modify
    @param value the new value

    @return the modified list
} {

    set itu_id                 [template::util::mobile_number::get_property itu_id $mobile_number_list]
    set national_number        [template::util::mobile_number::get_property national_number $mobile_number_list]
    set subscriber_number      [template::util::mobile_number::get_property subscriber_number $mobile_number_list]
    set best_contact_time      [template::util::mobile_number::get_property best_contact_time $mobile_number_list]

    switch $what {
        itu_id {
            return [list $value $national_number $subscriber_number $best_contact_time]
        }
        national_number {
            return [list $itu_id $value $subscriber_number $best_contact_time]
        }
        subscriber_number {
            return [list $itu_id $national_number $value $best_contact_time]
        }
        best_contact_time {
            return [list $itu_id $national_number $subscriber_number $value]
        }
        default {
            error "Parameter supplied to util::mobile_number::set_property 'what' must be one of: 'itu_id', 'subscriber_number', 'national_number', 'best_contact_time'. You specified: '$what'."
        }
    }
}

ad_proc -public template::util::mobile_number::get_property { what mobile_number_list } {
    
    Get a property of the mobile_number datatype. Valid properties are: 
    
    @param what the name of the property. Must be one of:
    <ul>
    <li>itu_id (synonyms street_mobile_number, street)
    <li>national_number (synonyms city, town)
    <li>subscriber_number (synonyms zip_code, zip)
    <li>addtional_text (this is not implemented in the default US widget)
    <li>best_contact_time (this is not implemented in the default US widget)
    <li>html_view - this returns an nice html formatted view of the mobile_number
    </ul>
    @param mobile_number_list a mobile_number datatype value, usually created with ad_form.
} {

    switch $what {
        itu_id {
            return [lindex $mobile_number_list 0]
        }
        national_number {
            return [lindex $mobile_number_list 1]
        }
        subscriber_number {
            return [lindex $mobile_number_list 2]
        }
        best_contact_time {
            return [lindex $mobile_number_list 3]
        }
        html_view {
            set itu_id                 [template::util::mobile_number::get_property itu_id $mobile_number_list]
            set subscriber_number      [template::util::mobile_number::get_property subscriber_number $mobile_number_list]
            set national_number        [template::util::mobile_number::get_property national_number $mobile_number_list]
            set best_contact_time      [template::util::mobile_number::get_property best_contact_time $mobile_number_list]
            return [template::util::mobile_number::html_view $itu_id $national_number $subscriber_number $best_contact_time]
        }
        default {
            error "Parameter supplied to util::mobile_number::get_property 'what' must be one of: 'itu_id', 'subscriber_number', 'national_number', 'best_contact_time'. You specified: '$what'."
        }
        
    }
}

ad_proc -public template::widget::mobile_number { element_reference tag_attributes } {
    Implements the mobile_number widget.
} {

  upvar $element_reference element

#  if { [info exists element(html)] } {
#    array set attributes $element(html)
#  }

#  array set attributes $tag_attributes

  if { [info exists element(value)] } {
      set itu_id                 [template::util::mobile_number::get_property itu_id $element(value)]
      set national_number        [template::util::mobile_number::get_property national_number $element(value)]
      set subscriber_number      [template::util::mobile_number::get_property subscriber_number $element(value)]
      set best_contact_time      [template::util::mobile_number::get_property best_contact_time $element(value)]
  } else {
      set itu_id                 {}
      set subscriber_number      {}
      set national_number        {}
      set best_contact_time      {}
  }
  
  set output {}

  if { [string equal $element(mode) "edit"] } {
      set attributes(id) \"mobile_number__$element(form_id)__$element(id)\"
      set summary_number ""
      if { [exists_and_not_null national_number] } {
          if { $national_number != "1" } {
              append summary_number "011-$national_number"
          }
      }
      if { [exists_and_not_null subscriber_number] } {
          if { [exists_and_not_null summary_number] } { append summary_number "-" }
          append summary_number $subscriber_number
      }
      append output "<input type=\"text\" name=\"$element(id).summary_number\" value=\"[ad_quotehtml $summary_number]\" size=\"20\">"
          
  } else {
      # Display mode
      if { [info exists element(value)] } {
          append output "[template::util::mobile_number::get_property html_view $element(value)]"
          append output "<input type=\"hidden\" name=\"$element(id).itu_id\" value=\"[ad_quotehtml $itu_id]\">"
          append output "<input type=\"hidden\" name=\"$element(id).national_number\" value=\"[ad_quotehtml $national_number]\">"
          append output "<input type=\"hidden\" name=\"$element(id).subscriber_number\" value=\"[ad_quotehtml $subscriber_number]\">"
          append output "<input type=\"hidden\" name=\"$element(id).best_contact_time\" value=\"[ad_quotehtml $best_contact_time]\">"
      }
  }
      
  return $output
}

ad_proc -public template::util::aim::status_img {
    -username:required
} {
# connecting to the server can be really slow, so we reutrn a url that will load in the broswer
# but not slow the loading of a page overall

    # Connect to AOL server
#    set url [socket "big.oscar.aol.com" 80]
    # Send request
#    puts $url "GET /$username?on_url=online&off_url=offline HTTP/1.0\n\n"
#    set counter 0
    # While page not completely read
#    while { ![eof $url] } {
	# Read page
#	set page [read $url 256]
#	incr counter
	# If we reach 10 attempts with no answer, consider the user offline
#	if { $counter > 10 } {
#	    set page "offline"
#	    break
#	}
#    }

    # If no time out, response will be formatted as:
    # HTTP/1.1 302 Redirection Location:online IMG SRC=online
    # or
    # HTTP/1.1 302 Redirection Location:online IMG SRC=offline
    # Search for word offline, if present then user is offline, else user is online

#    set status [string first "offline" $page]
#    if { $status >= 0 } {
#	set status "offline"
#    } else {
#	set status "online"
#    }
#    close $url
#    return status
    return "<img src=\"http://big.oscar.aol.com/$username?on_url=&off_url=\" />"
}

ad_proc -private template::util::skype::status {
    -username:required
    -response_type:required
    {-image_type "balloon"}
    {-language "en"}
    {-char_set "utf"}
} {
    This procedure would query the skypeweb database for the status of the provided username. For this procedure to retun the user status, the user should allow his status to be shown on the web in the privacy menu in thier Skype application. This procedure should not be called by the user, instead use the wrapper procedures status_txt, status_xml, status_num, and status_img, unless if you want the raw unprocessed result as it returns from the server. For more information consult the SkypeWeb Technical Whitepaper.

    @param username The username to check the status for.
    @param response_type
    Must be one of the following:
    <ul>
    <li><strong>txt</strong> - Returns status as a text. </li>
    <li><strong>xml</strong> - Returns status in XML format. </li>
    <li><strong>num</strong> - Returns status in a number code format. </li>
    <li><strong>img</strong> - Returns status as an image (PNG). </li>
    <li><strong>img_url</strong> - Returns status as an image url (PNG). </li>
    </ul>
    @param image_type
    If response_type is of type image, then image_type specifies the type of image to be returned. Available image types are:
    <ul>
    <li><strong>balloon</strong></li>
    <li><strong>big_classic</strong></li>
    <li><strong>small_classic</strong></li>
    <li><strong>small_icon</strong></li>
    <li><strong>medium_icon</strong></li>
    <li><strong>dropdown_white_bg</strong></li>
    <li><strong>dropdown_transparent_bg</strong</li>
    </ul>
    @param language The ISO code for the language that the status should be returned in. If specified language is not available, status would be returned in enlgish. Would only have meaning if response_type is txt.
    @param char_set The character set the status should be encoded in. Must be either utf (UTF-8) or iso (ISO-8859-1). Would only have meaning if response_type is txt.
} {
    #Set base URI
    set uri "http://mystatus.skype.com"

    #If response_type is image, add to URI the image type to return
    if { $response_type == "img" } {
	switch $image_type {
	    "balloon"                 {set image_type "balloon"}
	    "big_classic"             {set image_type "bigclassic"}
	    "small_classic"           {set image_type "smallclassic"}
	    "small_icon"              {set image_type "smallicon"}
	    "medium_icon"             {set image_type "mediumicon"}
	    "dropdown_white_bg"       {set image_type "dropdown-white"}
	    "dropdown_transparent_bg" {set image_type "dropdown-trans"}
	    default                   {set image_type "balloon"}
	}
	set uri ${uri}/$image_type
    }

    #To avoid ambiguity, escape the . in a username, then add it to the URI
    regsub -all {\.} $username {%2E} username
    set uri ${uri}/$username

    #If response_type is not an image, append it to the URI
    if { $response_type != "img" } {
	set uri ${uri}.$response_type
    }
    
    #If response_type is txt, check for language and character set.
    if { $response_type == "txt" } {

	#If language is specified, check for its availablity and add it to the URI
	if { ![empty_string_p $language] } {
	    string tolower $language
	    switch $language {
		"en"    {set language "en"}
		"de"    {set language "de"}
		"fr"    {set language "fr"}
		"it"    {set language "it"}
		"pl"    {set language "pl"}
		"ja"    {set language "ja"}
		"pt"    {set language "pt"}
		"pt/br" {set language "pt-br"}
		"se"    {set language "se"}
		"zh"    {set language "zh-cn"}
		"cn"    {set language "zh-cn"}
		"zh/cn" {set language "zh-cn"}
		"hk"    {set language "zh-tw"}
		"tw"    {set language "zh-tw"}
		"zh/tw" {set language "zh-tw"}
		default {set language "en"}
	    }
	    set uri ${uri}.$language
	}
	
	#If char_set is specified append it to the URI
	if { ![empty_string_p $char_set] } {
	    string tolower $char_set
	    switch $char_set {
		"utf"   {set char_set "utf8"}
		"iso"   {set char_set "latin1"}
		default {set char_set "utf8"}
	    }
	    set uri ${uri}.$char_set
	}
    }

    #By now, the uri is fully formatted and contains all the data required.

    if { $response_type eq "img" } {
	set status $uri
    } else {
	#Get user status
	set status [ns_httpget $uri]
    }

    return $status
}

ad_proc -public template::util::skype::status_txt {
    -username:required
    {-language ""}
    {-char_set ""}
} {
    This procedure is a wrapper procedure for template::util::skype::status, and should be used to get a text of the use status.

    @param username The username to check the status for.
    @param language The ISO code for the language that the status should be returned in. If specified language is not available, status would be returned in enlgish. Defaults to english.
    @param char_set The character set the status should be encoded in. Must be either utf (UTF-8) or iso (ISO-8859-1).

    @see template::util::skype::status
} {
    return [template::util::skype::status -username $username -response_type "txt" -language $language -char_set $char_set]
}

ad_proc -public template::util::skype::status_num {
    -username:required
} {
    This procedure is a wrapper procedure for template::util::skype::status. Will get a number code from the skypeweb server, and will decode it and return a text representation of the status.

    @param username The username to check the status for.

    @see template::util::skype::status
} {
    set status [template::util::skype::status -username $username -response_type "num"]

    switch $status {
	0 {set status "Unknown"}
	1 {set status "Offline"}
	2 {set status "Online"}
	3 {set status "Away"}
	4 {set status "Not Available"}
	5 {set status "Do Not Disturb"}
	6 {set status "Invisible"}
	7 {set status "Skype Me"}
    }
    return $status
}

ad_proc -public template::util::skype::status_xml {
    -username:required
    {-language}
} {
    This procedure is a wrapper procedure for template::util::skype::status. Will get an XML response, and will parse it and return a text representation of the status.

    @param username The username to check the status for.
    @param language The ISO code for the language that the status should be returned in. If specified language is not available, status would be returned in enlgish. Defaults to english.

    @see template::util::skype::status
} {
    set status [template::util::skype::status -username $username -response_type "xml"]

    #Parse XML response
    set document [dom parse $status]
    set root [$document documentElement]
    set node [$root firstChild]
    set node [$node firstChild]
    set nodelist [$node selectNodes /rdf/status/presence/text()]

    if { [empty_string_p $language] } {
	set language "en"
    }
    switch $language {
	string tolower $language
	"en"    {set status [lindex $nodelist 1]}
	"fr"    {set status [lindex $nodelist 2]}
	"de"    {set status [lindex $nodelist 3]}
	"ja"    {set status [lindex $nodelist 4]}
	"zh"    {set status [lindex $nodelist 5]}
	"cn"    {set status [lindex $nodelist 5]}
	"zh/cn" {set status [lindex $nodelist 5]}
	"hk"    {set status [lindex $nodelist 6]}
	"tw"    {set status [lindex $nodelist 6]}
	"zh/tw" {set status [lindex $nodelist 6]}
	"pt"    {set status [lindex $nodelist 7]}
	"pt/br" {set status [lindex $nodelist 8]}
	"it"    {set status [lindex $nodelist 9]}
	"es"    {set status [lindex $nodelist 10]}
	"pl"    {set status [lindex $nodelist 11]}
	"se"    {set status [lindex $nodelist 12]}
	default {set status [lindex $nodelist 1]}
    }
    return $status
}

ad_proc -public template::util::skype::status_img {
    -username:required
    {-image_type ""}
} {
    This procedure is a wrapper procedure for template::util::skype::status, and should be used to get an image of the users status.

    @param username The username to check the status for.
    @param image_type
    image_type specifies the type of image to be returned. Defaults to balloon. Available image types are:
    <ul>
    <li><strong>balloon</strong></li>
    <li><strong>big_classic</strong></li>
    <li><strong>small_classic</strong></li>
    <li><strong>small_icon</strong></li>
    <li><strong>medium_icon</strong></li>
    <li><strong>dropdown_white_bg</strong></li>
    <li><strong>dropdown_transparent_bg</strong</li>
    </ul>

    @see template::util::skype::status
} {
    #The status image url for a png image
    set uri [template::util::skype::status -username $username -response_type "img" -image_type $image_type]

    return "<img src=\"$uri\" />"
}

