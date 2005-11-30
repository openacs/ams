ad_page_contract {

    Update sort order

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    option_id:integer,notnull
    {attribute_id ""}
} -validate {
    option_has_no_entries -requires {option_id} { 
	if {[empty_string_p $attribute_id]} {
	    if { ![string match [db_string get_count { select count(*) from ams_option_types where option_id = :option_id } -default {0}] {0}] } {
		ad_complain [_ ams.lt_You_cannot_delete_an_]
	    }
	}
    }
}

if {[empty_string_p $attribute_id]} {

    # Delete the option for good
    
    db_1row get_option_info { select * from ams_options where option_id = :option_id }
    db_dml delete_option { delete from ams_options where option_id = :option_id }
} else {
    
    # Just unmap the option
    
    db_dml unmap_option { delete from ams_option_types where option_id = :option_id and attribute_id = :attribute_id }
}


ad_returnredirect -message "[_ ams.Option_Deleted]" "attribute?[export_vars -url {attribute_id}]"
