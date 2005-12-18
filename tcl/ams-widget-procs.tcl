ad_library {

    Support procs for the ams package

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-09-28
    @cvs-id $Id$

}

namespace eval ams {}
namespace eval ams::widget {}
namespace eval ams::util {}
namespace eval ams::attribute::save {}

ad_proc -public ams::widget {
    -widget:required
    -request:required
    {-attribute_id ""}
    {-attribute_name ""}
    {-pretty_name ""}
    {-form_name ""}
    {-value ""}
    {-optional_p "1"}
    {-locale ""}
} {
    This proc defers its responses to all other <a href="/api-doc/proc-search?show_deprecated_p=0&query_string=ams::widget::&source_weight=0&param_weight=3&name_weight=5&doc_weight=2&show_private_p=1&search_type=All+matches">ams::widget::${widget}</a> procs.

    @param widget the <a href="/api-doc/proc-search?show_deprecated_p=0&query_string=ams::widget::&source_weight=0&param_weight=3&name_weight=5&doc_weight=2&show_private_p=1&search_type=All+matches">ams::widget::${widget}</a> we defer to
    @param request
    must be one of the following:
    <ul>
    <li><strong>ad_form_widget</strong> - returns element(s) string(s) suitable for inclusion in the form section of <a href="/api-doc/proc-view?proc=ad_form">ad_form</a></li>
    <li><strong>template_form_widget</strong> - </li>
    <li><strong>form_set_value</strong> - sets the form value(s), in both ad_form and template_form using the <a href="/api-doc/proc-view?proc=template::element::set_value">template::element::set_value</a> proc</li>
    <li><strong>form_save_value</strong> - saves the form value(s), and returns a value_id suitable for inclusion in the ams_attribute_values table. This value_id can be an object_id or any other integer id. The value id is used by the value_method command to get a value suitable for use with ams::widget procs.</li>
    <li><strong>value_text</strong> - returns the value formatted as text/plain</li>
    <li><strong>value_html</strong> - returns the value formatted as text/html</li>
    <li><strong>csv_value</strong> - not yet implemented</li>
    <li><strong>csv_headers</strong> - not yet implemented</li>
    <li><strong>csv_save</strong> - not yet implemented</li>
    <li><strong>widget_datetypes</strong> - the acs_datatype(s) associated with this widget</li>
    <li><strong>widget_name</strong> - a pretty (human readable) name for this widget</li>
    <li><strong>value_method</strong> - the name of a database procedure to be called when returning a value to this procedure. The procedure will only get the value_id supplied in the form_save_value request and must convert that to whatever format it wants. In the simplest case it would return the value_id itself and then when you use form_set_value, value_text, value_html, csv_value actions a trip would need to be made to the database to return the appropriate values. If at all possible this procedure should return all the information necessary to format the value with this procedure (and thus not require another trip to the database which would siginifcantly decrease performance).</li>
    </ul>
    @param attribute_name
    @param pretty_name The name for the widget or to be used as a description of the attribute value
    @param form_name The name of the template_form or ad_form being used
    @param value The attribute value to be manipulated by this widget
    @param optional_p Whether or not an answer to this widget is required
} {

    if { [::ams::widget_proc_exists_p -widget $widget] } {
        switch $request {
            ad_form_widget - template_form_widget - form_save_value {
		if { [::ams::widget_has_options_p -widget $widget] } {
		    set options [::ams::widget_options -attribute_id $attribute_id] 
		} else {
		    set options {}
		}
	    }
            value_text - value_html {
                if { [exists_and_not_null value] } {
                    if { [::ams::widget_has_options_p -widget $widget] } {
                        set output [list]
                        foreach option [::ams::widget_options -attribute_id $attribute_id -locale $locale] {
                            if { [lsearch $value [lindex $option 1]] >= 0 } {
                                lappend output [lindex $option 0]
                            }
                        }
                        set value [join $output "\n"]
                    }
                }
                set options {}
            }
	    default {
		set options {}
	    }
	}
	ns_log Debug "MGEDDERT DEBUG: 	return ::ams::widget::${widget} -request $request -attribute_name $attribute_name -pretty_name $pretty_name -value $value -optional_p $optional_p -form_name $form_name -options $options"
	return [::ams::widget::${widget} -request $request -attribute_name $attribute_name -pretty_name $pretty_name -value $value -optional_p $optional_p -form_name $form_name -options $options]
    } else {
	# the widget requested did not exist
	ns_log Debug "AMS: the ams widget \"${widget}\" was requested and the associated ::ams::widget::${widget} procedure does not exist"

    }
}

ad_proc -private ams::widget_options {
    -attribute_id:required
    {-locale ""}
} {
    Return all widget procs. Each list element is a list of the first then pretty_name then the widget
} {
    set return_list [list]
    db_foreach get_options {} {
	set pretty_name "[lang::util::localize $pretty_name $locale]"
	lappend return_list [list $pretty_name $option_id]
    }
    return $return_list
}

ad_proc -private ams::widget_list {
} {
    Return all widget procs. Each list element is a list of the first then pretty_name then the widget
} {
    set widgets [list]
    set all_procs [::info procs "::ams::widget::*"]
    foreach widget $all_procs {
			 if { [string is false [regsub {__arg_parser} $widget {} widget]] } {
			     regsub {::ams::widget::} $widget {} widget
			     lappend widgets [list [::ams::widget -widget $widget -request "widget_name"] $widget]
			 }
 }
    return $widgets
}

ad_proc -private ams::widgets_init {
} {
    Initialize all widgets. Deprecated widgets that no longer exist in the tcl api.
} {
    set proc_widgets [list]
    foreach widget [ams::widget_list] {
	lappend proc_widgets [lindex $widget 1]
    }
    set sql_list_of_valid_procs "'[join $proc_widgets {','}]'"
    db_transaction {
        db_foreach select_widgets_to_deactivate "" {
	    set active_p 0
	    db_1row save_widget {}
	}
        foreach widget $proc_widgets {
            # is the widget in the database?
            set pretty_name  [ams::widget -widget $widget -request "widget_name"]
            set value_method [ams::widget -widget $widget -request "value_method"]
            set active_p 1
            db_1row save_widget {}
        }
    }
}

ad_proc -private ams::widget_proc_exists_p {
    -widget:required
} {
    Does the procedure ams::widget::\${widget} exist?

    @return 0 if false 1 if true
} {
    return [string is false [empty_string_p [info procs "::ams::widget::${widget}"]]]
}

ad_proc -private ams::widget_has_options_p {
    -widget:required
} {
    Is the procedure ams::widget::\${widget} one that depends on options?

    @return 0 if false 1 if true
} {
    if { [ams::widget_proc_exists_p -widget $widget] } {
	if { [ams::widget -widget $widget -request "value_method"] == "ams_value__options" } {
	    return 1
	} else {
	    return 0
	}
    } else {
	return 0
    }
}


ad_proc -private ams::widget::postal_address {
    -request:required
    -attribute_name:required
    -pretty_name:required
    -form_name:required
    -value:required
    -optional_p:required
    -options:required
} {
    This proc responds to the ams::widget procs.

    @see ams::widget
} {

    switch $request {
        ad_form_widget  {
	    if { [string is true $optional_p] } {
		return "${attribute_name}:address(address),optional {[list label ${pretty_name}]}"
	    } else {
		return "${attribute_name}:address(address) {[list label ${pretty_name}]}"
	    }
	}
        template_form_widget  {
	    if { [string is true $optional_p] } {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype address \
		    -widget address \
		    -optional
	    } else {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype address \
		    -widget address
	    }
	}
        form_set_value {
	    ::template::element::set_value ${form_name} ${attribute_name} ${value}
	}
        form_save_value {
	    set value [::template::element::get_value ${form_name} ${attribute_name}]
	    return [ams::util::postal_address_save \
			-delivery_address [template::util::address::get_property delivery_address $value] \
                        -municipality [template::util::address::get_property municipality $value] \
                        -region [template::util::address::get_property region $value] \
                        -postal_code [template::util::address::get_property postal_code $value] \
                        -country_code [template::util::address::get_property country_code $value] \
                        -additional_text [template::util::address::get_property additional_text $value] \
                        -postal_type [template::util::address::get_property postal_type $value]]
	}
        value_text {
            foreach {delivery_address municipality region postal_code country_code additional_text postal_type} $value {}
	    return [ad_html_to_text -showtags -no_format [template::util::address::html_view $delivery_address $municipality $region $postal_code $country_code $additional_text $postal_type]]
	}
        value_html {
            foreach {delivery_address municipality region postal_code country_code additional_text postal_type} $value {}
	    return [template::util::address::html_view $delivery_address $municipality $region $postal_code $country_code $additional_text $postal_type]
	}
	value_list {
            foreach {delivery_address municipality region postal_code country_code additional_text postal_type} $value {}
	    return [list [list delivery_address $delivery_address] [list municipality $municipality] [list region $region] [list postal_code $postal_code] [list country_code $country_code] [list additional_text $additional_text] [list postal_type $postal_type]]
	}
        csv_value {
	    # not yet implemented
	}
        csv_headers {
	    # not yet implemented
	}
        csv_save {
	    # not yet implemented
	}
	widget_datatypes {
	    return [list "string"]
	}
	widget_name {
	    return [_ "ams.Address"]
	}
	value_method {
	    return "ams_value__postal_address"
	}
    }
}


ad_proc -private ams::widget::telecom_number {
    -request:required
    -attribute_name:required
    -pretty_name:required
    -form_name:required
    -value:required
    -optional_p:required
    -options:required
} {
    This proc responds to the ams::widget procs.

    @see ams::widget
} {

    switch $request {
        ad_form_widget  {
	    if { [string is true $optional_p] } {
		return "${attribute_name}:telecom_number(telecom_number),optional {[list label ${pretty_name}]}"
	    } else {
		return "${attribute_name}:telecom_number(telecom_number) {[list label ${pretty_name}]}"
	    }
	}
        template_form_widget  {
	    if { [string is true $optional_p] } {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype telecom_number \
		    -widget telecom_number \
		    -optional
	    } else {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype telecom_number \
		    -widget telecom_number
	    }
	}
        form_set_value {
	    ::template::element::set_value ${form_name} ${attribute_name} $value
	}
        form_save_value {
	    set value [::template::element::get_value ${form_name} ${attribute_name}]
	    return [ams::util::telecom_number_save \
			-itu_id [template::util::telecom_number::get_property itu_id $value] \
			-national_number [template::util::telecom_number::get_property national_number $value] \
			-area_city_code [template::util::telecom_number::get_property area_city_code $value] \
			-subscriber_number [template::util::telecom_number::get_property subscriber_number $value] \
			-extension [template::util::telecom_number::get_property extension $value] \
			-sms_enabled_p [template::util::telecom_number::get_property sms_enabled_p $value] \
			-best_contact_time [template::util::telecom_number::get_property best_contact_time $value] \
			-location [template::util::telecom_number::get_property location $value] \
			-phone_type_id [template::util::telecom_number::get_property phone_type_id $value]]
	}
        value_text {
            foreach {itu_id national_number area_city_code subscriber_number extension sms_enabled_p best_contact_time location phone_type_id} $value {}
	    return [ad_html_to_text -showtags -no_format [template::util::telecom_number::html_view $itu_id $national_number $area_city_code $subscriber_number $extension $sms_enabled_p $best_contact_time $location $phone_type_id]]
	}
        value_html {
            foreach {itu_id national_number area_city_code subscriber_number extension sms_enabled_p best_contact_time location phone_type_id} $value {}
	    return [template::util::telecom_number::html_view $itu_id $national_number $area_city_code $subscriber_number $extension $sms_enabled_p $best_contact_time $location $phone_type_id]
	}
        csv_value {
	    # not yet implemented
	}
        csv_headers {
	    # not yet implemented
	}
        csv_save {
	    # not yet implemented
	}
	widget_datatypes {
	    return [list "string"]
	}
	widget_name {
	    return [_ "ams.Telecom_Number"]
	}
	value_method {
	    return "ams_value__telecom_number"
	}
    }
}


ad_proc -private ams::widget::date {
    -request:required
    -attribute_name:required
    -pretty_name:required
    -form_name:required
    -value:required
    -optional_p:required
    -options:required
} {
    This proc responds to the ams::widget procs.

    @see ams::widget
} {

    switch $request {
        ad_form_widget  {
	    if { [string is true $optional_p] } {
		return "${attribute_name}:date(date),optional {[list label ${pretty_name}]}"
	    } else {
		return "${attribute_name}:date(date) {[list label ${pretty_name}]}"
	    }
	}
        template_form_widget  {
	    if { [string is true $optional_p] } {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype date \
		    -widget date \
		    -help \
		    -optional
	    } else {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype date \
		    -widget date \
		    -help
	    }
	}
        form_set_value {
            regsub -all {\-} $value { } value
            regsub -all {:} $value { } value
	    ::template::element::set_value ${form_name} ${attribute_name} ${value}
	}
        form_save_value {
	    set value [::template::element::get_value ${form_name} ${attribute_name}]
	    return [ams::util::time_save -time [template::util::date::get_property ansi $value]]
	}
        value_text {
	    return [lc_time_fmt $value %q]
	}
        value_html {
	    return [ad_html_text_convert -from "text/plain" -to "text/html" [lc_time_fmt $value %q]]
	}
        csv_value {
	    # not yet implemented
	}
        csv_headers {
	    # not yet implemented
	}
        csv_save {
	    # not yet implemented
	}
	widget_datatypes {
	    return [list "date"]
	}
	widget_name {
	    return [_ "ams.Date"]
	}
	value_method {
	    return "ams_value__time"
	}
    }
}


ad_proc -private ams::widget::select {
    -request:required
    -attribute_name:required
    -pretty_name:required
    -form_name:required
    -value:required
    -optional_p:required
    -options:required
} {
    This proc responds to the ams::widget procs.

    @see ams::widget
} {

    switch $request {
        ad_form_widget  {
	    if { [string is true $optional_p] } {
		set options [concat [list [list "" ""]] $options]
		return "${attribute_name}:integer(select),optional {[list label ${pretty_name}]} {[list options $options]}"
	    } else {
		set options [concat [list [list "- [_ ams.select_one] -" ""]] $options]
		return "${attribute_name}:integer(select) {[list label ${pretty_name}]} {[list options $options]}"
	    }
	}
        template_form_widget  {
	    if { [string is true $optional_p] } {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype integer \
		    -widget select \
		    -optional
	    } else {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype integer \
		    -widget select
	    }
	}
        form_set_value {
	    ::template::element::set_value ${form_name} ${attribute_name} ${value}
	}
        form_save_value {
	    set value [::template::element::get_value ${form_name} ${attribute_name}]
	    return [ams::util::options_save -options $value]
	}
        value_text {
	    return ${value}
	}
        value_html {
	    return [ad_html_text_convert -from "text/plain" -to "text/html" -- ${value}]
	}
        csv_value {
	    # not yet implemented
	}
        csv_headers {
	    # not yet implemented
	}
        csv_save {
	    # not yet implemented
	}
	widget_datatypes {
	    return [list "string"]
	}
	widget_name {
	    return [_ "ams.Select"]
	}
	value_method {
	    return "ams_value__options"
	}
    }
}


ad_proc -private ams::widget::radio {
    -request:required
    -attribute_name:required
    -pretty_name:required
    -form_name:required
    -value:required
    -optional_p:required
    -options:required
} {
    This proc responds to the ams::widget procs.

    @see ams::widget
} {

    switch $request {
        ad_form_widget  {
	    if { [string is true $optional_p] } {
		return "${attribute_name}:integer(radio),optional {[list label ${pretty_name}]} {[list options $options]}"
	    } else {
		return "${attribute_name}:integer(radio) {[list label ${pretty_name}]} {[list options $options]}"
	    }
	}
        template_form_widget  {
	    if { [string is true $optional_p] } {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype integer \
		    -widget radio \
		    -optional
	    } else {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype integer \
		    -widget radio
	    }
	}
        form_set_value {
	    ::template::element::set_value ${form_name} ${attribute_name} ${value}
	}
        form_save_value {
	    set value [::template::element::get_value ${form_name} ${attribute_name}]
	    return [ams::util::options_save -options $value]
	}
        value_text {
	    return ${value}
	}
        value_html {
	    return [ad_html_text_convert -from "text/plain" -to "text/html" -- ${value}]
	}
        csv_value {
	    # not yet implemented
	}
        csv_headers {
	    # not yet implemented
	}
        csv_save {
	    # not yet implemented
	}
	widget_datatypes {
	    return [list "string"]
	}
	widget_name {
	    return [_ "ams.Radio"]
	}
	value_method {
	    return "ams_value__options"
	}
    }
}


ad_proc -private ams::widget::checkbox {
    -request:required
    -attribute_name:required
    -pretty_name:required
    -form_name:required
    -value:required
    -optional_p:required
    -options:required
} {
    This proc responds to the ams::widget procs.

    @see ams::widget
} {

    switch $request {
        ad_form_widget  {
	    if { [string is true $optional_p] } {
		return "${attribute_name}:integer(checkbox),multiple,optional {[list label ${pretty_name}]} {[list options $options]}"
	    } else {
		return "${attribute_name}:integer(checkbox),multiple {[list label ${pretty_name}]} {[list options $options]}"
	    }
	}
        template_form_widget  {
	    if { [string is true $optional_p] } {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype integer \
		    -widget checkbox \
		    -multiple \
		    -optional
	    } else {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype integer \
		    -widget checkbox \
		    -multiple
	    }
	}
        form_set_value {
	    ::template::element::set_values ${form_name} ${attribute_name} ${value}
	}
        form_save_value {
	    set values [::template::element::get_values ${form_name} ${attribute_name}]
	    return [ams::util::options_save -options $values]
	}
        value_text {
	    return ${value}
	}
        value_html {
	    return [ad_html_text_convert -from "text/plain" -to "text/html" -- ${value}]
	}
        csv_value {
	    # not yet implemented
	}
        csv_headers {
	    # not yet implemented
	}
        csv_save {
	    # not yet implemented
	}
	widget_datatypes {
	    return [list "string"]
	}
	widget_name {
	    return [_ "ams.Checkbox"]
	}
	value_method {
	    return "ams_value__options"
	}
    }
}


ad_proc -private ams::widget::multiselect {
    -request:required
    -attribute_name:required
    -pretty_name:required
    -form_name:required
    -value:required
    -optional_p:required
    -options:required
} {
    This proc responds to the ams::widget procs.

    @see ams::widget
} {

    switch $request {
        ad_form_widget  {
	    if { [string is true $optional_p] } {
		return "${attribute_name}:integer(multiselect),multiple,optional {[list label ${pretty_name}]} {[list options $options]}"
	    } else {
		return "${attribute_name}:integer(multiselect),multiple {[list label ${pretty_name}]} {[list options $options]}"
	    }
	}
        template_form_widget  {
	    if { [string is true $optional_p] } {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype integer \
		    -widget multiselect \
		    -multiple \
		    -optional
	    } else {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype integer \
		    -widget multiselect \
		    -multiple
	    }
	}
        form_set_value {
	    ::template::element::set_values ${form_name} ${attribute_name} ${value}
	}
        form_save_value {
	    set values [::template::element::get_values ${form_name} ${attribute_name}]
	    return [ams::util::options_save -options $values]
	}
        value_text {
	    return ${value}
	}
        value_html {
	    return [ad_html_text_convert -from "text/plain" -to "text/html" -- ${value}]
	}
        csv_value {
	    # not yet implemented
	}
        csv_headers {
	    # not yet implemented
	}
        csv_save {
	    # not yet implemented
	}
	widget_datatypes {
	    return [list "string"]
	}
	widget_name {
	    return [_ "ams.Multiselect"]
	}
	value_method {
	    return "ams_value__options"
	}
    }
}




ad_proc -private ams::widget::integer {
    -request:required
    -attribute_name:required
    -pretty_name:required
    -form_name:required
    -value:required
    -optional_p:required
    -options:required
} {
    This proc responds to the ams::widget procs.

    @see ams::widget
} {

    switch $request {
        ad_form_widget  {
	    if { [string is true $optional_p] } {
		return "${attribute_name}:integer(text),optional {html {size 6}} {[list label ${pretty_name}]}"
	    } else {
		return "${attribute_name}:integer(text) {html {size 6}} {[list label ${pretty_name}]}"
	    }
	}
        template_form_widget  {
	    if { [string is true $optional_p] } {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype integer \
		    -widget text \
		    -html {size 6} \
		    -optional
	    } else {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype integer \
		    -widget text \
		    -html {size 6}
	    }
	}
        form_set_value {
	    ::template::element::set_value ${form_name} ${attribute_name} ${value}
	}
        form_save_value {
	    set value [::template::element::get_value ${form_name} ${attribute_name}]
	    return [ams::util::number_save -number $value]
	}
        value_text {
	    return ${value}
	}
        value_html {
	    return [ad_html_text_convert -from "text/plain" -to "text/html" -- ${value}]
	}
        csv_value {
	    # not yet implemented
	}
        csv_headers {
	    # not yet implemented
	}
        csv_save {
	    # not yet implemented
	}
	widget_datatypes {
	    return [list "integer"]
	}
	widget_name {
	    return [_ "ams.Integer"]
	}
	value_method {
	    return "ams_value__number"
	}
    }
}


ad_proc -private ams::widget::textbox {
    -request:required
    -attribute_name:required
    -pretty_name:required
    -form_name:required
    -value:required
    -optional_p:required
    -options:required
} {
    This proc responds to the ams::widget procs.

    @see ams::widget
} {
    # We save this value to use in the display
    set org_value $value

    # We escape all characters, since you can't use a string that has "{" "}" "[" "]"  as a list
    regsub -all {[\]\[\{\}\"\\$]} $value {\\&} value
    set value_format [lindex $value 0]
    set value [lrange $value 1 end]
    switch $request {
        ad_form_widget  {
	    if { [string is true $optional_p] } {
		return "${attribute_name}:text(text),optional {html {size 30}} {[list label ${pretty_name}]}"
	    } else {
		return "${attribute_name}:text(text) {html {size 30}} {[list label ${pretty_name}]}"
	    }
	}
        template_form_widget  {
	    if { [string is true $optional_p] } {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype text \
		    -widget text \
		    -html {size 30} \
		    -optional
	    } else {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype text \
		    -widget text \
		    -html {size 30}
	    }
	}
        form_set_value {
	    ::template::element::set_value ${form_name} ${attribute_name} ${value}
	}
        form_save_value {
	    set value [::template::element::get_value ${form_name} ${attribute_name}]
	    return [ams::util::text_save -text $value -text_format "text/plain"]
	}
        value_text {
	    # We return the original string here without the format part otherwise it will return scaped characters
	    set value [string range $org_value [expr [string length $value_format] + 1] [string length $org_value]]
	    return ${value}
	}
	value_html {
	    # We return the original string here without the format part otherwise it will return scaped characters
	    set value [string range $org_value [expr [string length $value_format] + 1] [string length $org_value]]
	    return [ad_html_text_convert -from "text/plain" -to "text/html" -- ${value}]
	}
        csv_value {
	    # not yet implemented
	}
        csv_headers {
	    # not yet implemented
	}
        csv_save {
	    # not yet implemented
	}
	widget_datatypes {
	    return [list "string"]
	}
	widget_name {
	    return [_ "ams.Textbox"]
	}
	value_method {
	    return "ams_value__text"
	}
    }
}


ad_proc -private ams::widget::textarea {
    -request:required
    -attribute_name:required
    -pretty_name:required
    -form_name:required
    -value:required
    -optional_p:required
    -options:required
} {
    This proc responds to the ams::widget procs.

    @see ams::widget
} {
    # We save this value to use in the display
    set org_value $value

    # We escape all characters, since you can't use a string that has "{" "}" "[" "]"  as a list
    regsub -all {[\]\[\{\}\"\\$]} $value {\\&} value
    set value_format [lindex $value 0]
    set value [lrange $value 1 end]
    switch $request {
        ad_form_widget  {
	    if { [string is true $optional_p] } {
		return "${attribute_name}:text(textarea),optional {html {cols 60 rows 6}} {[list label ${pretty_name}]}"
	    } else {
		return "${attribute_name}:text(textarea) {html {cols 60 rows 10}} {[list label ${pretty_name}]}"
	    }
	}
        template_form_widget  {
	    if { [string is true $optional_p] } {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype text \
		    -widget textarea \
		    -html {cols 60 rows 10} \
		    -optional
	    } else {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype text \
		    -widget textarea \
		    -html {cols 60 rows 10}
	    }
	}
        form_set_value {
	    ::template::element::set_value ${form_name} ${attribute_name} ${value}
	}
        form_save_value {
	    set value [::template::element::get_value ${form_name} ${attribute_name}]
	    return [ams::util::text_save -text $value -text_format "text/plain"]
	}
        value_text {
	    # We return the original string here without the format part otherwise it will return scaped characters
	    set value [string range $org_value [expr [string length $value_format] + 1] [string length $org_value]]
	    return ${value}
	}
        value_html {
	    # We return the original string here without the format part otherwise it will return scaped characters
	    set value [string range $org_value [expr [string length $value_format] + 1] [string length $org_value]]
#	    return [ad_html_text_convert -from "text/plain" -to "text/html" -- ${value}]
	    return ${value}
	}
        csv_value {
	    # not yet implemented
	}
        csv_headers {
	    # not yet implemented
	}
        csv_save {
	    # not yet implemented
	}
	widget_datatypes {
	    return [list "text"]
	}
	widget_name {
	    return [_ "ams.Textarea"]
	}
	value_method {
	    return "ams_value__text"
	}
    }
}


ad_proc -private ams::widget::richtext {
    -request:required
    -attribute_name:required
    -pretty_name:required
    -form_name:required
    -value:required
    -optional_p:required
    -options:required
} {
    This proc responds to the ams::widget procs.

    @see ams::widget
} {
    set value_format [lindex $value 0]
    set value [lrange $value 1 end]
    switch $request {
        ad_form_widget  {
	    if { [string is true $optional_p] } {
		return "${attribute_name}:richtext(richtext),optional {html {cols 60 rows 14}} {[list label ${pretty_name}]}"
	    } else {
		return "${attribute_name}:richtext(richtext) {html {cols 60 rows 14}} {[list label ${pretty_name}]}"
	    }
	}
        template_form_widget  {
	    if { [string is true $optional_p] } {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype richtext \
		    -widget richtext \
		    -html {cols 60 rows 14} \
		    -optional
	    } else {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype richtext \
		    -widget richtext \
		    -html {cols 60 rows 14}
	    }
	}
        form_set_value {
	    ::template::element::set_value ${form_name} ${attribute_name} [list ${value} ${value_format}]
	}
        form_save_value {
	    set value [::template::element::get_value ${form_name} ${attribute_name}]
	    return [ams::util::text_save \
			-text [template::util::richtext::get_property contents $value] \
			-text_format [template::util::richtext::get_property format $value]]
	}
        value_text {
	    return ${value}
	}
        value_html {
#	    return [ad_html_text_convert -from "text/plain" -to "text/html" -- ${value}]
	    return ${value}
	}
        csv_value {
	    # not yet implemented
	}
        csv_headers {
	    # not yet implemented
	}
        csv_save {
	    # not yet implemented
	}
	widget_datatypes {
	    return [list "text"]
	}
	widget_name {
	    return [_ "ams.Richtext"]
	}
	value_method {
	    return "ams_value__text"
	}
    }
}


ad_proc -private ams::widget::email {
    -request:required
    -attribute_name:required
    -pretty_name:required
    -form_name:required
    -value:required
    -optional_p:required
    -options:required
} {
    This proc responds to the ams::widget procs.

    @see ams::widget
} {
    set value_format [lindex $value 0]
    set value [lrange $value 1 end]
    switch $request {
        ad_form_widget  {
	    if { [string is true $optional_p] } {
		return "${attribute_name}:email(text),optional {html {size 30}} {[list label ${pretty_name}]}"
	    } else {
		return "${attribute_name}:email(text) {html {size 30}} {[list label ${pretty_name}]}"
	    }
	}
        template_form_widget  {
	    if { [string is true $optional_p] } {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype email \
		    -widget text \
		    -html {size 30} \
		    -optional
	    } else {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype email \
		    -widget text \
		    -html {size 30}
	    }
	}
        form_set_value {
	    ::template::element::set_value ${form_name} ${attribute_name} ${value}
	}
        form_save_value {
	    set value [::template::element::get_value ${form_name} ${attribute_name}]
	    return [ams::util::text_save -text $value -text_format "text/plain"]
	}
        value_text {
	    return ${value}
	}
        value_html {
	    return [ad_html_text_convert -from "text/plain" -to "text/html" -- ${value}]
	}
        csv_value {
	    # not yet implemented
	}
        csv_headers {
	    # not yet implemented
	}
        csv_save {
	    # not yet implemented
	}
	widget_datatypes {
	    return [list "email"]
	}
	widget_name {
	    return [_ "ams.Email"]
	}
	value_method {
	    return "ams_value__text"
	}
    }
}


ad_proc -private ams::widget::url {
    -request:required
    -attribute_name:required
    -pretty_name:required
    -form_name:required
    -value:required
    -optional_p:required
    -options:required
} {
    This proc responds to the ams::widget procs.

    @see ams::widget
} {
    set value_format [lindex $value 0]
    set value [lrange $value 1 end]
    switch $request {
        ad_form_widget  {
	    if { [string is true $optional_p] } {
		return "${attribute_name}:url(text),optional {html {size 30}} {[list label ${pretty_name}]}"
	    } else {
		return "${attribute_name}:url(text) {html {size 30}} {[list label ${pretty_name}]}"
	    }
	}
        template_form_widget  {
	    if { [string is true $optional_p] } {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype url \
		    -widget text \
		    -html {size 30} \
		    -optional
	    } else {
		::template::element::create ${form_name} ${attribute_name} \
		    -label ${pretty_name} \
		    -datatype url \
		    -widget text \
		    -html {size 30}
	    }
	}
        form_set_value {
	    ::template::element::set_value ${form_name} ${attribute_name} ${value}
	}
        form_save_value {
	    set value [::template::element::get_value ${form_name} ${attribute_name}]
	    return [ams::util::text_save -text $value -text_format "text/plain"]
	}
        value_text {
	    return ${value}
	}
        value_html {
	    return [ad_html_text_convert -from "text/plain" -to "text/html" -- ${value}]
	}
        csv_value {
	    # not yet implemented
	}
        csv_headers {
	    # not yet implemented
	}
        csv_save {
	    # not yet implemented
	}
	widget_datatypes {
	    return [list "url"]
	}
	widget_name {
	    return [_ "ams.Url"]
	}
	value_method {
	    return "ams_value__text"
	}
    }
}

ad_proc -private ams::util::text_save {
    -text:required
    -text_format:required
} {
    return a value_id     
} {
    if { [exists_and_not_null text] } {
	return [db_string save_value {} -default {}]
    }
}

ad_proc -private ams::util::time_save {
    -time:required
} {
    return a value_id     
} {
    if { [exists_and_not_null time] } {
	return [db_string save_value {} -default {}]
    }
}

ad_proc -private ams::util::number_save {
    -number:required
} {
    return a value_id     
} {
    if { [exists_and_not_null number] } {
    return [db_string save_value {} -default {}]
    }
}

ad_proc -private ams::util::postal_address_save {
    -delivery_address:required
    -municipality:required
    -region:required
    -postal_code:required
    -country_code:required
    {-additional_text ""}
    {-postal_type ""}
} {
    return a value_id     
} {
    if { [exists_and_not_null delivery_address] } {
	return [db_string save_value {} -default {}]
    }
}

ad_proc -private ams::util::telecom_number_save {
    {-itu_id ""}
    {-national_number ""}
    {-area_city_code ""}
    -subscriber_number:required
    {-extension ""}
    {-sms_enabled_p ""}
    {-best_contact_time ""}
    {-location ""}
    {-phone_type_id ""}
} {
    return a value_id     
} {
    if { [exists_and_not_null subscriber_number] } {
	return [db_string save_value {} -default {}]
    }
}

ad_proc -public ams::util::options_save {
    -options:required
} {
    Map an ams option for an attribute to an option_map_id, if no value is supplied for option_map_id a new option_map_id will be created.

    @param option_map_id
    @param option_id

    @return option_map_id
} {
    set options [lsort $options]
    set value_id [db_string options_value_id {} -default {}]
    if { [string is false [exists_and_not_null value_id]] } {
	foreach option_id $options {
	    set value_id [db_string option_map {}]
	}
    }
    return $value_id
}



#########################
# Quick Procs for Saving
#########################

ad_proc -public ams::attribute::save::text {
    -object_id:required
    {-attribute_id ""}
    {-attribute_name ""}
    {-object_type ""}
    {-format "text/plain"}
    -value
} {
    Save the value of an AMS text attribute for an object.
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-07-22
    
    @param object_id The object for which the value is stored
    
    @param attribute_id The attribute_id of the attribute for which the value is retrieved
    
    @param attribute_name Alternatively the attribute_name for the attribute
    
    @return
    
    @error
} {
    if {[exists_and_not_null value]} {
	if {[empty_string_p $attribute_id]} {
	    set attribute_id [attribute::id \
				  -object_type "$object_type" -attribute_name "$attribute_name"]
	}
	if {[exists_and_not_null attribute_id]} {

	    set value_id [ams::util::text_save \
			      -text $value \
			      -text_format "text/plain"]
	    ams::attribute::value_save -object_id $object_id -attribute_id $attribute_id -value_id $value_id
	}
    }
}

ad_proc -public ams::attribute::save::number {
    -object_id:required
    {-attribute_id ""}
    {-attribute_name ""}
    {-object_type ""}
    {-format "text/plain"}
    -number
} {
    Save the value of an AMS text attribute for an object.
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-07-22
    
    @param object_id The object for which the value is stored
    
    @param attribute_id The attribute_id of the attribute for which the value is retrieved
    
    @param attribute_name Alternatively the attribute_name for the attribute
    
    @param number The number value to save
    @return
    
    @error
} {
    if {[exists_and_not_null value]} {
	if {[empty_string_p $attribute_id]} {
	    set attribute_id [attribute::id \
				  -object_type "$object_type" -attribute_name "$attribute_name"]
	}
	if {[exists_and_not_null attribute_id]} {
	    set value_id [ams::util::number_save -number $number]
	    ams::attribute::value_save -object_id $object_id -attribute_id $attribute_id -value_id $value_id
	}
    }
}

ad_proc -public ams::attribute::save::timestamp {
    -object_id:required
    {-attribute_id ""}
    {-attribute_name ""}
    {-object_type ""}
    {-format "text/plain"}
    -month
    -day
    -year
    -hour
    -minute
} {
    Save the value of an AMS timestamp attribute for an object.
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-07-22
    
    @param object_id The object for which the value is stored
    
    @param attribute_id The attribute_id of the attribute for which the value is retrieved
    
    @param attribute_name Alternatively the attribute_name for the attribute

    @param month Month of the object to store
    @param day Day of the object to store
    @param year Year of the object
    @param hour Hour of the object
    @param minute Minute of the object
    
    @return
    
    @error
} {
    if {[empty_string_p $attribute_id]} {
	set attribute_id [attribute::id \
			      -object_type "$object_type" -attribute_name "$attribute_name"]
    }
    if {[exists_and_not_null attribute_id]} {
	set value_id [ams::util::time_save -time "$month-$day-$year $hour:$minute"]
	ams::attribute::value_save -object_id $object_id -attribute_id $attribute_id -value_id $value_id
    }
}

ad_proc -public ams::attribute::save::postal_address {
    -object_id:required
    {-attribute_id ""}
    {-attribute_name ""}
    {-object_type ""}
    {-format "text/plain"}
    -delivery_address:required
    -municipality:required
    -region:required
    -postal_code:required
    -country_code:required
    {-additional_text ""}
    {-postal_type ""}
} {
    Save the value of an AMS timestamp attribute for an object.
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-07-22
    
    @param object_id The object for which the value is stored
    
    @param attribute_id The attribute_id of the attribute for which the value is retrieved
    
    @param attribute_name Alternatively the attribute_name for the attribute

    @param delivery_address Street Information
    @param municipality City/Town
    @param region Region
    @param postal_code Postal / ZIP Code
    @param country_code Country Code of the address
    @param additional_text Additional text for the address
    @param postal_type Addtional postal type information
    
    @return
    
    @error
} {
    if {[empty_string_p $attribute_id]} {
	set attribute_id [attribute::id \
			      -object_type "$object_type" -attribute_name "$attribute_name"]
    }
    if {[exists_and_not_null attribute_id]} {
	set value_id [ams::util::postal_address_save \
			  -delivery_address $delivery_address \
			  -municipality $municipality \
			  -region $region \
			  -postal_code $postal_code \
			  -country_code $country_code \
			  -additional_text $additional_text \
			  -postal_type $postal_type]
	ams::attribute::value_save -object_id $object_id -attribute_id $attribute_id -value_id $value_id
    }
}


ad_proc -public ams::attribute::save::simple_phone_number {
    -object_id:required
    {-attribute_id ""}
    {-attribute_name ""}
    {-object_type ""}
    -phone_number:required
} {
    Save the value of an AMS timestamp attribute for an object.
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-07-22
    
    @param object_id The object for which the value is stored
    
    @param attribute_id The attribute_id of the attribute for which the value is retrieved
    
    @param attribute_name Alternatively the attribute_name for the attribute

    @param phone_number  The simple phone number without any extras

    @return
    
    @error
} {

    if {[empty_string_p $attribute_id]} {
	set attribute_id [attribute::id \
			      -object_type "$object_type" -attribute_name "$attribute_name"]
    }
    if {[exists_and_not_null attribute_id]} {

	set value_id [ams::util::telecom_number_save -subscriber_number $phone_number]
	ams::attribute::value_save -object_id $object_id -attribute_id $attribute_id -value_id $value_id
    }
}


ad_proc -public ams::attribute::save::mc {
    -object_id:required
    {-attribute_id ""}
    {-attribute_name ""}
    {-object_type ""}
    -value
    {-format "text/plain"}
} {
    Save the value of an AMS multiple choice attribute like "select",
    "radio"  for an object.
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-07-22
    
    @param object_id The object for which the value is stored
    
    @param attribute_id The attribute_id of the attribute for which the value is retrieved
    
    @param attribute_name Alternatively the attribute_name for the attribute

    @return
    
    @error
} {
    if {[exists_and_not_null value]} {
	# map values if corresponding mapping-function
	# exists
	
	set proc "map_$attribute_name"
	
	if {[llength [info procs $proc]] == 1} {
	    if {[exists_and_not_null value]} {
		if {[catch {set value [eval $proc {$value}]} err]} {
		    append error_string "Contact \#$contact_count ($first_names $last_name): $err<br>"
		}
	    }
	}
    }
    
    if {[exists_and_not_null value]} {

	if {[empty_string_p $attribute_id]} {
	    set attribute_id [attribute::id \
				  -object_type "$object_type" -attribute_name "$attribute_name"]
	}

	switch $value {
	    "TRUE" {set value "t" }
	    "FALSE" {set value "f" }
	}
	set option_id [db_string get_option {select option_id from ams_option_types where attribute_id = :attribute_id and option = :value} \
			   -default {}]

	# Create the option if it no already existed.
	if {![exists_and_not_null option_id]} {
	    set option_id [ams::option::new \
			       -attribute_id $attribute_id \
			       -option $value]
	    ns_log notice "...... CREATED OPTION $option_id: $value"
	}
	
	# Save the value using the option_id
	set value_id [ams::util::options_save \
			  -options $option_id]
	ams::attribute::value_save -object_id $object_id -attribute_id $attribute_id -value_id $value_id
	ns_log Notice "AMS MC:: $object_id  - $attribute_id - $value_id"
    }
}