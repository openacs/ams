ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {ams_attribute_id:integer,notnull}
    {object_type:notnull}
    {widget_name:notnull}
    {attribute_name:notnull}
    {pretty_name:notnull}
    {pretty_plural:notnull}
    {list_id:integer}
    {description ""}
}

acs_object_type::get -object_type $object_type -array "object_info"

set title "[_ ams.Define_Options]"
set context [list [list objects Objects] [list "object?object_type=$object_type" $object_info(pretty_name)] [list "attribute-add?object_type=$object_type" "[_ ams.Add_Attribute]"] $title]

db_1row select_widget_pretty_and_storage_type { select storage_type from ams_widgets where widget_name = :widget_name }

acs_object_type::get -object_type $object_type -array "object_info"




if { [exists_and_not_null list_id] } {
    set return_url "list-attributes-map?[export_vars -url {ams_attribute_id list_id}]"
    set user_message "[_ ams.lt_AMS_Attribute_a_hrefa]"
} else {
    set return_url "object?[export_vars -url {object_type}]"
    set user_message "[_ ams.lt_AMS_Attribute_a_hrefa_1]"
}




if { ![string equal $storage_type "ams_options"] } {

    ams::attribute::new \
        -ams_attribute_id $ams_attribute_id \
        -object_type $object_type \
        -attribute_name $attribute_name \
        -pretty_name $pretty_name \
        -pretty_plural $pretty_plural \
        -description $description \
        -widget_name $widget_name

#    {-options}

    util_user_message -html -message $user_message
    ad_returnredirect $return_url
    ad_script_abort
}

ad_form -name attribute_form -form {
    {ams_attribute_id:key}
    {list_id:integer(hidden)}
    {object_type:text(hidden)}
    {widget_name:text(inform) {label "[_ ams.Widget_1]"}}
    {attribute_name:text(inform) {label "[_ ams.Attribute_Name]"}}
    {pretty_name:text(inform) {label "[_ ams.Pretty_Name_1]"}}
    {pretty_plural:text(inform) {label "[_ ams.Pretty_Plural_1]"}}
}

if { [exists_and_not_null description] } {
    ad_form -extend -name attribute_form -form {
        {description:text(inform) {label "[_ ams.Description]"}}
    }
} else {
    ad_form -extend -name attribute_form -form {
        {description:text(hidden),optional} 
    }
}

ad_form -extend -name attribute_form -form {
    {option1:text {label "[_ ams.Option_1]"} {html {size 50}}}
    {option2:text,optional {label "[_ ams.Option_2]"} {html {size 50}}}
    {option3:text,optional {label "[_ ams.Option_3]" } {html {size 50}}}
    {option4:text,optional {label "[_ ams.Option_4]" } {html {size 50}}}
    {option5:text,optional {label "[_ ams.Option_5]"} {html {size 50}}}
    {option6:text,optional {label "[_ ams.Option_6]"} {html {size 50}}}
    {option7:text,optional {label "[_ ams.Option_7]"} {html {size 50}}}
    {option8:text,optional {label "[_ ams.Option_8]"} {html {size 50}}}
    {option9:text,optional {label "[_ ams.Option_9]"} {html {size 50}} {help_text {If you need to add more options you will be able to do so by editing this attributes details}}}
} -new_request {
} -edit_request {
} -validate {
} -on_submit {

    set i 1
    set options {}
    while { $i <= "9" } {
        set option_value [string trim [set option${i}]]
        ns_log notice $option_value
        if { [exists_and_not_null option_value] } {
            lappend options $option_value
        }
        incr i
    }

    ams::attribute::new \
        -ams_attribute_id $ams_attribute_id \
        -object_type $object_type \
        -attribute_name $attribute_name \
        -pretty_name $pretty_name \
        -pretty_plural $pretty_plural \
        -description $description \
        -widget_name $widget_name \
        -options $options

} -after_submit {
    util_user_message -html -message $user_message
    ad_returnredirect $return_url
    ad_script_abort
}

    
ad_return_template
