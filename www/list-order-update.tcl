ad_page_contract {

    Update sort order

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    sort_key:array
    list_id:integer,notnull
} -validate {
    ordering_is_valid -requires {sort_key} {
	set no_value_supplied [list]
	set no_integer_supplied [list]
	set used_sort_orders [list]
	set doubled_sort_orders [list]
	foreach {attribute_id sort_order} [array get sort_key] {
	    set sort_order [string trim $sort_order]
	    if { $sort_order == "" } {
		lappend no_value_supplied $attribute_id
	    } elseif { [string is false [string is integer $sort_order]] } {
		lappend no_integer_supplied $attribute_id $sort_order
	    } elseif { [info exists order($sort_order)] } {
		lappend doubled_sort_orders $attribute_id $order($sort_order)
	    } else {
		set order($sort_order) $attribute_id
	    }
	}
	set error_messages [list]
	if { [llength $no_value_supplied] } {
	    foreach attribute_id $no_value_supplied {
		lappend error_messages "[_ ams.No_ordering_integer_was_supplied_for] <strong>[attribute::pretty_name -attribute_id $attribute_id]</strong>"
	    }
	}
	if { [llength $no_integer_supplied] } {
	    foreach { attribute_id sort_order } $no_integer_supplied {
		lappend error_messages "[_ ams.The_ordering_number_is_not_an_integer_for] <strong>[attribute::pretty_name -attribute_id $attribute_id]</strong>"
	    }
	}
	if { [llength $doubled_sort_orders] } {
	    foreach { one_attribute_id two_attribute_id } $doubled_sort_orders {
		lappend error_messages "[_ ams.The_ordering_number_is_the_same_for] <strong>[attribute::pretty_name -attribute_id $one_attribute_id]</strong> [_ ams.and] <strong>[attribute::pretty_name -attribute_id $two_attribute_id]</strong>"
	    }
	}
	if { [llength $error_messages] > 0 } {
	    foreach message $error_messages {
		ad_complain $message
	    }
	}
    }
}

set attribute_order [list]
set sort_key_list [array get sort_key]
foreach {attribute_id sort_order} $sort_key_list {
    set order($sort_order) $attribute_id
    lappend attribute_order $sort_order
}
set ordered_list [lsort -integer $attribute_order]	

set highest_sort [db_string get_highest_sort { select sort_order from ams_list_attribute_map where list_id = :list_id order by sort_order desc limit 1 }]
incr highest_sort
set sort_number 1
db_transaction {
    foreach sort_order $ordered_list {
	set attribute_id $order($sort_order)
	db_dml update_sort_order { update ams_list_attribute_map set sort_order = :highest_sort where sort_order = :sort_number and list_id = :list_id }
	db_dml update_sort_order { update ams_list_attribute_map set sort_order = :sort_number where attribute_id = :attribute_id and list_id = :list_id }
	incr highest_sort
	incr sort_number
    }
}

ams::list::get -list_id $list_id -array "list_info"
set package_key $list_info(package_key)
set object_type $list_info(object_type)
set list_name $list_info(list_name)

ad_returnredirect "list?[export_vars -url {package_key object_type list_name}]"
ad_script_abort

ad_returnredirect "object-map?object_id=$object_id"
