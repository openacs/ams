ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {object_type:notnull}
    {list_id:integer}
}

acs_object_type::get -object_type $object_type -array "object_info"

set title "Add Attribute"
set context [list [list objects Objects] [list "object?object_type=$object_type" $object_info(pretty_name)] "Add Attribute"]

set widget_options " [db_list_of_lists select_widgets { select widget_name, widget_name from ams_widgets order by widget_name } ]"


ad_form -name attribute_form -form {
    {ams_attribute_id:key}
    {list_id:integer(hidden)}
    {object_type:text(hidden)}
    {widget_name:text(multiselect) {label "Widget"} {options $widget_options } {help_text {<a href="widgets">Widgets descriptions</a> are available}}}
    {attribute_name:text {label "Attribute Name"} {html {size 30 maxlength 100}} {help_text {This name must be lower case, contain only letters and underscores, and contain no spaces}}}
    {pretty_name:text {label "Pretty Name"} {html {size 30 maxlength 100}}}
    {pretty_plural:text {label "Pretty Plural"} {html {size 30 maxlength 100}}}
    {description:text(textarea),optional {label "Description"} {html {cols 55 rows 4}}}
} -new_request {
} -edit_request {
} -validate {
    # i need to add validation that the attribute isn't already in the database
    { attribute_name 
        { [::regexp {^([0-9]|[a-z]|\_){1,}$} $attribute_name match attribute_name_validate] } 
        "You have used invalid characters."
    }
    { attribute_name 
        { ![::attribute::exists_p $object_type $attribute_name] } 
        "Attribute $attribute_name already exists for <a href=\"object?[export_vars -url {object_type}]\">$object_info(pretty_name)</a>."
    }
} -on_submit {
} -new_data {
} -edit_data {
} -after_submit {
    ad_returnredirect "attribute-add-2?[export_vars -url {ams_attribute_id object_type widget_name attribute_name pretty_name pretty_plural description list_id}]"
    ad_script_abort
}

    
ad_return_template
