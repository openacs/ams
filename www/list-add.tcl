ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {object_type:notnull}
    {package_key ""}
    {list_name ""}
    {pretty_name ""}
    {description ""}
    {return_url ""}
    {return_url_label ""}
}

acs_object_type::get -object_type $object_type -array "object_info"

set title "[_ ams.Add_List]"
set context [list [list objects Objects] [list "object?object_type=$object_type" $object_info(pretty_name)] "[_ ams.Add_List]"]

set package_options " [db_list_of_lists select_packages { select package_key, package_key from apm_package_types order by package_key } ]"

if { [exists_and_not_null package_key] && [exists_and_not_null object_type] && [exists_and_not_null list_name] } {
    ams::list::flush -package_key $package_key -object_type $object_type -list_name $list_name
}

ad_form -name list_form -form {
    {list_id:key}
    {package_key:text(select) {label "[_ ams.Package_Key_1]"} {options $package_options}}
    {object_type:text(inform) {label "[_ ams.Object_Type_1]"}}
    {list_name:text {label "[_ ams.List_Name_1]"} {html {size 30 maxlength 100}} {help_text {[_ ams.lt_This_name_must_be_low]}}}
    {pretty_name:text {label "[_ ams.Pretty_Name_1]"} {html {size 30 maxlength 100}}}
    {description:text(textarea),optional {label "[_ ams.Description]"} {html {cols 55 rows 4}}}
    return_url:text(hidden),optional
    return_url_label:text(hidden),optional
} -new_request {
    set uneditable_attributes [list package_key object_type list_name pretty_name description]
    set blank_required_attributes [list]
    foreach attribute $uneditable_attributes {
	if { [set $attribute] != "" } {
	    template::element::set_properties list_form $attribute mode display
	} else {
	    if { $attribute != "description" } {
		lappend blank_required_attributes $attribute
	    }
	}
    }
    # if the only blank attribute is description we can create this list (since all the data was
    # provided by the request of this page
    if { [string is false [exists_and_not_null blank_required_attributes]] } {
	util_user_message -replace
	ams::list::flush -package_key $package_key -object_type $object_type -list_name $list_name
	ams::list::new -package_key $package_key \
	    -object_type $object_type \
	    -list_name $list_name \
	    -pretty_name $pretty_name \
	    -description $description \
	    -description_mime_type "text/plain" \
	    -context_id ""
	ams::list::flush -package_key $package_key -object_type $object_type -list_name $list_name
	ad_returnredirect "list?[export_vars -url {package_key object_type list_name return_url return_url_label}]"
	ad_script_abort
    }
} -edit_request {
} -validate {
    # i need to add validation that the attribute isn't already in the database
    { list_name 
        { [::regexp {^([0-9]|[a-z]|\_){1,}$} $list_name match list_name_validate] } 
        "[_ ams.lt_You_have_used_invalid]"
    }
    { list_name
        { ![::ams::list::exists_p -package_key $package_key -object_type $object_type -list_name $list_name] } 
        "[_ ams.lt_List_name_a_hrefliste]"
    }
} -on_submit {

    ams::list::flush -package_key $package_key -object_type $object_type -list_name $list_name

    ams::list::new -list_id $list_id \
        -package_key $package_key \
        -object_type $object_type \
        -list_name $list_name \
        -pretty_name $pretty_name \
        -description $description \
        -description_mime_type "text/plain" \
        -context_id ""

    ams::list::flush -package_key $package_key -object_type $object_type -list_name $list_name


} -edit_data {
} -after_submit {
    ad_returnredirect "list?[export_vars -url {package_key object_type list_name return_url return_url_label}]"
    ad_script_abort
}

    
ad_return_template
