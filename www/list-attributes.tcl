ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    {attribute_id:integer,multiple}
    {list_id:integer,notnull}
    {command "map"}
    return_url:optional
    return_url_label:optional
}

# We get the lis info
ams::list::get -list_id $list_id -array "list_info"
set package_key $list_info(package_key)
set object_type $list_info(object_type)
set list_name $list_info(list_name)

set attribute_ids $attribute_id
# If we have contacts installed we can do some duplicate checking

if {[apm_package_installed_p "contacts"]} {
    # Now we are going to get the default 
    # list_id according to the object_type
    set contacts_package_id [lindex [split $list_id "__"] 0]
    set default_group [contacts::default_group -package_id $contacts_package_id]
    set default_list_name "${contacts_package_id}__${default_group}"
    set default_list_id [db_string get_default_list "" -default ""]
    if { [string equal $default_list_id $list_id] } {
	# We are assigning values to the default list
	# so we are going to get all the mapped atributes
	# for the other lists
	set name_first_part [lindex [split $list_name "__"] 0]
	set mapped_attributes_list [db_list get_attributes_list { }]
	set error_message "The_attribute_is_already"
    } else {
	# Not the default list. We get all the attributes 
	# of the default list_id
	set mapped_attributes_list [db_list get_default_attributes_list { }]
	set error_message "The_attribute_is_already_default"
    }

    # Before mapping any new attributes we check 
    # if they don't exist in the mapped attribute 
    # list, otherwise we would have duplicates
    
    foreach attribute_id $attribute_ids {
	if { ![string equal [lsearch $mapped_attributes_list $attribute_id] "-1"] } {
	    ad_return_complaint 1 "[_ ams.$error_message]"
	    ad_script_abort
	}
    }
}

# If it reachs this point it means that we can map all attributes.
foreach attribute_id $attribute_ids {
    ams::list::attribute::${command} -list_id $list_id -attribute_id $attribute_id
}

ad_returnredirect "list?[export_vars -url {package_key object_type list_name return_url return_url_label}]"
ad_script_abort
