ad_page_contract {
     

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    {attribute_id:integer,multiple,notnull}
    {list_id:integer,notnull}
    return_url:optional
    return_url_label:optional
}

foreach attribute_id $attribute_id {
    ams::list::attribute::optional -list_id $list_id -attribute_id $attribute_id
}

ams::list::get -list_id $list_id -array "list_info"
set package_key $list_info(package_key)
set object_type $list_info(object_type)
set list_name $list_info(list_name)

ad_returnredirect "list?[export_vars -url {package_key object_type list_name return_url return_url_label}]"
ad_script_abort
