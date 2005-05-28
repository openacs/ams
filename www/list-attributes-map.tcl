ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    {attribute_id:integer,multiple}
    {list_id:integer,notnull}
}

foreach attribute_id $attribute_id {
    ams::list::attribute::map -list_id $list_id -attribute_id $attribute_id
}

ams::list::get -list_id $list_id -array "list_info"
set package_key $list_info(package_key)
set object_type $list_info(object_type)
set list_name $list_info(list_name)

ad_returnredirect "list?[export_vars -url {package_key object_type list_name}]"
ad_script_abort
