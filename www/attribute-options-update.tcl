ad_page_contract {

    Update sort order

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    option:array
    sort_key:array
    ams_attribute_id:integer,notnull
}
# first we check to see if there are new options. 
# if yes we add them
foreach option_key [list new1 new2 new3] {
    set option_string [string trim $option(${option_key})]
    if { [exists_and_not_null option_string] } {
        set option_id [ams::option::new -ams_attribute_id $ams_attribute_id -option $option_string]
        set sort_key(${option_id}) $sort_key(${option_key})
    }
}

# now that all the options are in the database we get the "old" sort order
# if not value for sort_key is provided we will keep the same order as before
set option_ids [db_list get_option_ids { select option_id from ams_options where ams_attribute_id = :ams_attribute_id order by sort_order }]

# first we get the highest sort_order so variables without a sort_order can be given one
set highest_sort 0
foreach option_id $option_ids {
    if { $sort_key(${option_id}) > $highest_sort } {
        set highest_sort $sort_key(${option_id})
    } 
}


db_transaction {
    foreach option_id $option_ids {
        set sort_order $sort_key(${option_id})
        incr highest_sort
        db_dml update_sort_order { update ams_options set sort_order = :highest_sort where sort_order = :sort_order and ams_attribute_id = :ams_attribute_id }
        if { ![exists_and_not_null sort_order] } {
            incr highest_sort 1
            set sort_order $highest_sort 
        }
        db_dml update_sort_order { update ams_options set sort_order = :sort_order where option_id = :option_id }
    }
}
ams::attribute::flush -ams_attribute_id $ams_attribute_id
ad_returnredirect -message "Options Updated" "attribute?[export_vars -url {ams_attribute_id}]"
