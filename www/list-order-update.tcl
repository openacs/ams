ad_page_contract {

    Update sort order

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    sort_key:array
    list_id:integer,notnull
}


set attribute_ids [db_list get_attribute_ids { select attribute_id from ams_list_attribute_map where list_id = :list_id order by sort_order }]


# first we get the highest sort_order so variables without a sort_order can be given one
set highest_sort 0
set used_sorts [list]
foreach attribute_id $attribute_ids {
    if { $sort_key(${attribute_id}) > $highest_sort } {
        set highest_sort $sort_key(${attribute_id})
    }
}

db_transaction {
    foreach attribute_id $attribute_ids {
        set sort_order $sort_key(${attribute_id})
        incr highest_sort 1
        db_dml update_sort_order { update ams_list_attribute_map set sort_order = :highest_sort where sort_order = :sort_order and list_id = :list_id }
        if { ![exists_and_not_null sort_order] } {
            incr highest_sort 1
            set sort_order $highest_sort 
        }
        db_dml update_sort_order { update ams_list_attribute_map set sort_order = :sort_order where attribute_id = :attribute_id and list_id = :list_id }
    }
}

ams::list::get -list_id $list_id -array "list_info"
set package_key $list_info(package_key)
set object_type $list_info(object_type)
set list_name $list_info(list_name)

ad_returnredirect "list?[export_vars -url {package_key object_type list_name}]"
ad_script_abort

ad_returnredirect "object-map?object_id=$object_id"
