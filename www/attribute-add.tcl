ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {return_url:optional ""}
    {return_url_label:optional ""}
    {list_id:optional ""}
    {object_type:notnull}
    {widget:optional ""}
    {attribute_name:optional ""}
}

acs_object_type::get -object_type $object_type -array "object_info"

set title "[_ ams.Add_Attribute]"
set context [list [list objects Objects] [list "object?object_type=$object_type" $object_info(pretty_name)] "[_ ams.Add_Attribute]"]

ad_form -name attribute_form -form {
    {ams_attribute_id:key}
    {return_url:text(hidden),optional}
    {return_url_label:text(hidden),optional}
    {list_id:integer(hidden),optional}
    {object_type:text(hidden)}
    {mode:text(hidden),optional}
    {widget:text(radio),optional {label "[_ ams.Widget_1]"} {options {[lsort [::ams::widget_list]]}}}
    {attribute_name:text,optional {label "[_ ams.Attribute_Name]"} {html {size 30 maxlength 100}} {help_text {This name must be lower case, contain only letters and underscores, and contain no spaces. If not specified one will be generated for you.}}}
    {pretty_name:text,optional {label "[_ ams.Pretty_Name_1]"} {html {size 30 maxlength 100}}}
    {pretty_plural:text,optional {label "[_ ams.Pretty_Plural_1]"} {html {size 30 maxlength 100}}}
}


#if { [ams::widget_has_options_p -widget $widget] } {
#    foreach elemement [list option1 option2 option3 option4 option4] {
#	::template::element::set_properties attribute_form $element -widget text
#    }
#}
if { [ams::widget_has_options_p -widget $widget] } {
    set default_number_of_options 5
    set option_fields_count $default_number_of_options
    set i 1
    set elements [list]
    lappend elements [list option_fields_count:integer(hidden) [list value $option_fields_count]]
#    lappend elements [list options_on_last_screen:integer(hidden),optional]
    while { $i <= $option_fields_count } {
	set element [list option${i}:text(text),optional [list label "[_ ams.Option_i]"] [list html [list size 50]]]
        if { $i == $option_fields_count } {
	    lappend element [list help_text "[_ ams.lt_If_you_need_to_add_mo]"]
	}
        if { $i == 1 } {
	    lappend element [list section "[_ ams.Predefined_Options]"]
	}
	lappend elements $element
        incr i
    }
    ad_form -extend -name attribute_form -form $elements
}



ad_form -extend -name attribute_form -on_request {
    set mode "new"
    if { [::attribute::exists_p -convert_p 0 $object_type $attribute_name] } {
	# this attribute already exists - so we are in "edit" mode for
	::template::element::set_properties attribute_form attribute_name -mode display
        db_1row get_attr_info { select pretty_name, pretty_plural from acs_attributes where attribute_name = :attribute_name and object_type = :object_type }
        set mode "edit"
    }
    if { [exists_and_not_null widget] } {
	if { [string is false [ams::widget_proc_exists_p -widget $widget]] } {
	    ad_return_error "[_ ams.lt_There_was_a_problem_w]" "[_ ams.lt_The_widget_specified_]"
	}
        ::template::element::set_properties attribute_form widget -widget select -mode display
    }
    set option_on_last_screen 1
#::template::element set_properties attribute_form pretty_plural -widget hidden
#    foreach field [list attribute_name pretty_name pretty_plural] {
#	::template::element set_properties attribute_form $field -mode display
#    }
} -on_submit {
    ams::widgets_init
    if { [exists_and_not_null attribute_name] } {
        if { [string is false [::regexp {^([0-9]|[a-z]|\_){1,}$} $attribute_name match attribute_name_matcher]] } {
	    ::template::form::set_error attribute_form attribute_name "[_ ams.lt_You_have_used_invalid]"
	} else {
	    ::template::element::set_properties attribute_form attribute_name -mode display
	}
    } else {
	if { [exists_and_not_null pretty_name] } {
	    set attribute_name [util_text_to_url -replacement "_" -text $pretty_name]
	    set attribute_name_generated_p 1
	    ::template::element::set_value attribute_form attribute_name $attribute_name
	}
    }
    set required_fields [list widget pretty_name pretty_plural]
    if { [exists_and_not_null option_fields_count] } {
	lappend required_fields "option1"
    }
    foreach required_field $required_fields {
	if { [string is false [exists_and_not_null ${required_field}]] } {
	    ::template::form::set_error attribute_form $required_field "[::template::element::get_property attribute_form $required_field label] is required"
	}
    }


    # Internationalising of Attributes. This is done by storing the attribute with it's acs-lang key
    set message_key "${object_type}_${attribute_name}"
    
    # Register the language keys
    lang::message::register en_US ams $message_key $pretty_name
    lang::message::register en_US ams "${message_key}_plural" $pretty_plural

    # Register the language key in the current user locale as well
    # Usually you would only register the key in the locale that the user is using
    # But we can't do this as the system depends on english language keys first.
    # If Timo manages to get the service contract with babblefish or dict.leo.org working
    # We might have an automatic translation first :).
    set user_locale [lang::user::locale]
    if {[exists_and_not_null user_locale]} {
        if {$user_locale != "en_US"} {
            lang::message::register $user_locale ams $message_key $pretty_name
            lang::message::register $user_locale ams "${message_key}_plural" $pretty_plural
        }
    }

    # Replace the pretty_name and pretty_plural with the message key, so it is inserted correctly in the database
    set pretty_name "#ams.${message_key}#"
    set pretty_plural "#ams.${message_key}_plural#"

    if { [exists_and_not_null widget] } {
	::template::element::set_properties attribute_form widget -widget select -mode display
    }
    if { $mode == "new" } {
	    if { [::attribute::exists_p -convert_p 0 $object_type $attribute_name] } {
		if { [exists_and_not_null attribute_name_generated_p] } {
		    set message "[_ ams.lt_The_attribute_name_au]"
		} else {
		    set message "[_ ams.lt_This_attribute_name_a]"
		}
		::template::element::set_error attribute_form attribute_name $message 
		::template::element::set_properties attribute_form attribute_name -mode edit 
	    }
    }
#    ::template::form::set_error attribute_form attribute_name "$mode $attribute_name $object_type"

#    element::create attribute_form change_widget -datatype text -widget submit -label "Change Widget"
#        { ![::attribute::exists_p $object_type $attribute_name] } 
#        "Attribute $attribute_name already exists for <a href=\"object?[export_vars -url {object_type}]\">$object_info(pretty_name)</a>."

#    if { [exists_and_not_null option_fields_count] } {
#        if { xists_and_not_null options_on_last_screen] && [string is false [exists_and_not_null option1]] } {
#	    ::template::form::set_error attribute_form option1 "Option 1 is required"
#       } else {
#	    ::template::element::set_value attribute_form options_on_last_screen 1
#	}
#    }


    if { [::template::form::is_valid attribute_form] } {


	db_transaction {
	# the form has passed all validation blocks
#        ::template::element::set_error attribute_form attribute_name "valid"
	    if { $mode == "new" } {
		set attribute_id [attribute::new \
				      -object_type $object_type \
				      -attribute_name $attribute_name \
				      -datatype [::ams::widget -widget $widget -request "widget_datatypes"] \
				      -pretty_name $pretty_name \
				      -pretty_plural $pretty_plural]
		set dynamic_p 1
	    } else {
		set attribute_id [attribute::id \
				      -object_type $object_type \
				      -attribute_name $attribute_name]
		set dynamic_p 0
	    }
	    ams::attribute::new \
		-attribute_id $attribute_id \
		-ams_attribute_id $ams_attribute_id \
		-widget $widget \
		-dynamic_p $dynamic_p
	    
	    if { [ams::widget_has_options_p -widget $widget] && [exists_and_not_null option_fields_count] } {
                set i 1
		while { $i <= $option_fields_count } {
		    set option [set "option${i}"]
		    if { [exists_and_not_null option] } {
			ams::option::new \
			    -attribute_id $attribute_id \
			    -option $option
		    }
		    incr i
		}
	    }
	}
    } else {
        break
    }
} -after_submit {
    if { [exists_and_not_null list_id] } {
	ams::list::attribute::map -list_id $list_id -attribute_id $attribute_id
	ams::list::get -list_id $list_id -array list_info
	set list_name $list_info(list_name)
	set object_type $list_info(object_type)
	set package_key $list_info(package_key)
	set return_url [export_vars -base "list" -url {list_name object_type package_key return_url return_url_label}]
    } else {
	set return_url [export_vars -base "object" -url {object_type return_url return_url_label}]
    }
    ad_returnredirect -message "$pretty_name has been added as an attribute to $object_type#>" $return_url
    ad_script_abort
}

    
ad_return_template
