ad_page_contract {

    Update sort order

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    option_id:integer,notnull
} -validate {
    option_has_no_entries -requires {option_id} { 
        if { ![string match [db_string get_count { select count(*) from ams_option_map where option_id = :option_id } -default {0}] {0}] } {
            ad_complain {You cannot delete an option that already has entries on it}
        }
    }
}

db_1row get_option_info { select * from ams_options where option_id = :option_id }

db_dml delete_option { delete from ams_options where option_id = :option_id }


ad_returnredirect -message "Option Deleted" "attribute?[export_vars -url {ams_attribute_id}]"
