# packages/ams/tcl/ams-install-provs.tcl

ad_library {
    
    install procs for AMS
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-09-09
    @arch-tag: 329a828d-99b0-41cf-89f4-2f8f6b4cfaf5
    @cvs-id $Id$
}

namespace eval ams::install {}

ad_proc -public ams::install::after_upgrade {
    {-from_version_name:required}
    {-to_version_name:required}
} {
    apm_upgrade_logic \
        -from_version_name $from_version_name \
        -to_version_name $to_version_name \
        -spec {
	    1.1d2 1.1d3 {
		db_transaction {
		    db_foreach select_option_name {select option_id, option from ams_option_types} {
			set pretty_name [lang::util::convert_to_i18n -message_key "ams_option_$option_id" -text "$option"]
			ns_log Notice "prettry.::: $pretty_name"
			db_dml update_pretty_name  "update acs_objects set title = :pretty_name where object_id = :option_id"
		    }
		}
	    }
	    1.1d3 1.1d4 {
		apm_parameter_register "DefaultAdressLayoutP" "Especify the default template for input and display layout for the address. Set to 1 for { street, city, state, zip, country } or 0 for { street, zip, city, state, country }" "ams" "1" "number" "address-widget"
	    }
	}
}


