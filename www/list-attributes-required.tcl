ad_page_contract {
     

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    {ams_attribute_id:integer,multiple,notnull}
    {list_id:integer,notnull}
}

foreach ams_attribute_id $ams_attribute_id {
    ams::list::attribute::required -list_id $list_id -ams_attribute_id $ams_attribute_id
}

ams::list::get -list_id $list_id -array "list_info"
set package_key $list_info(package_key)
set object_type $list_info(object_type)
set list_name $list_info(list_name)

ad_returnredirect "list?[export_vars -url {package_key object_type list_name}]"
ad_script_abort
