ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
}

set title "Attribute Management System"
set context {}


# YOU NEED TO SPECIFY A VALID OBJECT_ID
#set object_id   "2864"

# Once done comment out the error line
#ad_return_error "You need to specify and valid object id in the packages/ams/www/index.tcl file" "Once done comment out this line."
set package_key      "ams"
set object_type      "ams_list"
set list_name        "ams_list_demo"
set list_name_pretty "The Fields used to Add/Edit a Contact Person"
ams::define_list $list_name $list_name_pretty $package_key $object_type {
        {first_names textbox {First Name(s)} {First Names} required}
        {middle_names textbox {Middle Name(s)} {Middle Names}}
        {last_name textbox {Last Name} {Last Names} required}
        {email email {Email Address} {Email Addresses}}
        {url url {Website} {Websites}}
        {home_address address {Home Address} {Home Addresses}}
        {organization_address address {Organization Address} {Organization Addresses}}
    }

set object_id [db_string get_list_id {
    select list_id
      from ams_lists
     where short_name = :list_name
       and package_key = :package_key
       and object_type = :object_type
}]

ad_form -name entry \
    -form [ams::ad_form::elements -key object_id $package_key $object_type $list_name] \
    -edit_request {
        ams::object::attribute::values -names -varenv $object_id
    } -on_submit {
        ams::ad_form::save entry $package_key $object_type $list_name $object_id
    } -after_submit {
        if { ![exists_and_not_null return_url] } {
            set return_url "./"
        }
    }

set attr_list [ams::object::attribute::values -names $object_id]

ad_return_template
