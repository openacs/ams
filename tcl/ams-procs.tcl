ad_library {

    Support procs for the ams package

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-09-28
    @cvs-id $Id$

}


namespace eval attribute:: {}
namespace eval ams:: {}
namespace eval ams::attribute {}
namespace eval ams::option {}
namespace eval ams::ad_form {}

ad_proc -public attribute::pretty_name {
    {-attribute_id:required}
} {
    get the pretty_name of an attribute
} {
    return [db_string get_pretty_name { select pretty_name from ams_attributes where attribute_id = :attribute_id } -default {}]
}

ad_proc -public attribute::pretty_plural {
    {-attribute_id:required}
} {
    get the pretty_plural of an attribute
} {
    return [db_string get_pretty_name { select pretty_plural from ams_attributes where attribute_id = :attribute_id } -default {}]
}

ad_proc -public attribute::new {
    -object_type:required
    -attribute_name:required
    -datatype:required
    -pretty_name:required
    -pretty_plural:required
    {-table_name ""}
    {-column_name ""}
    {-default_value ""}
    {-min_n_values "1"}
    {-max_n_values "1"}
    {-sort_order ""}
    {-storage "generic"}
    {-static_p "f"}
    {-if_does_not_exist:boolean}
} {
    create a new attribute

    @see ams::attribute::new
} {
    if { $if_does_not_exist_p } {
	set attribute_id [attribute::id -object_type $object_type -attribute_name $attribute_name]
	if { [string is false [exists_and_not_null attribute_id]] } {
	    set attribute_id [db_string create_attribute {}]
	}
    } else {
	set attribute_id [db_string create_attribute {}]
    }
    return $attribute_id
}

ad_proc -public attribute::id {
    -object_type:required
    -attribute_name:required
} {
    return the attribute_id for the specified attribute
} {
    return [db_string get_attribute_id {} -default {}]
}

ad_proc -public ams::package_id {} {

    TODO: Get the AMS package ID, not the connection package_id
    Get the package_id of the ams instance

    @return package_id
} {
    return [ad_conn package_id]
}

ad_proc -public ams::object_parents {
    -object_type:required
    -sql:boolean
    -hide_current:boolean
    -show_root:boolean
} {
    @param sql if selected the list will be formatted in a way suitable for inclusion in sql statements
    @param hide_current hide the current object_type
    @param show_root show the root object_type (the acs_object object type)
    @return a list of the parent object_types
} {
    if { [string is false $hide_current_p] } {
	set object_types [list $object_type]
    }
    while { $object_type != "acs_object" } {
	set object_type [db_string get_next_object_type { select supertype from acs_object_types where object_type = :object_type }]
	if { $object_type != "acs_object" } {
	    lappend object_types $object_type
	}
    }
    if { $show_root_p } {
	lappend object_types "acs_object"
    }
    if { $sql_p } {
	return "'[join $object_types "','"]'"
    } else {
	return $object_types
    }
}

ad_proc -public ams::object_copy {
    -from:required
    -to:required
} {
} {
    db_transaction {
	db_dml copy_object {
	    insert into ams_attribute_values
            (object_id,attribute_id,value_id)
            ( select :to,
                     attribute_id,
                     value_id
                from ams_attribute_values
               where object_id = :object_id )
	}
    }
}

ad_proc -public ams::attribute::get {
    -attribute_id:required
    -array:required
} {
    Get the info on an ams_attribute
} {
    upvar 1 $array row
    db_1row select_attribute_info { select * from ams_attributes where attribute_id = :attribute_id } -column_array row
}

ad_proc -public ams::attribute::new {
    -attribute_id:required
    {-ams_attribute_id ""}
    -widget:required
    {-dynamic_p "0"}
    {-deprecated_p "0"}
    {-context_id ""}
} {
    create a new ams_attribute

    @see attribute::new
} {
    set existing_ams_attribute_id [db_string get_it { select ams_attribute_id from ams_attributes where attribute_id = :attribute_id } -default {}]

    if { [exists_and_not_null existing_ams_attribute_id] } {
        return $existing_ams_attribute_id
    } else {
        set extra_vars [ns_set create]
        oacs_util::vars_to_ns_set -ns_set $extra_vars -var_list {attribute_id ams_attribute_id widget dynamic_p deprecated_p context_id}
        set ams_attribute_id [package_instantiate_object -extra_vars $extra_vars ams_attribute]
        return $ams_attribute_id
    }
}

ad_proc -public ams::attribute::value_save {
    -object_id:required
    -attribute_id:required
    -value_id:required
} {

    save and attribute value
} {
    db_exec_plsql attribute_value_save {}
}



ad_proc -public ams::option::new {
    {-option_id ""}
    -attribute_id:required
    -option:required
    {-sort_order ""}
    {-deprecated_p "0"}
    {-context_id ""}
} {
    Create a new ams option for an attribute
} {
    set extra_vars [ns_set create]
    oacs_util::vars_to_ns_set -ns_set $extra_vars -var_list {option_id attribute_id option sort_order deprecated_p}
    set option_id [package_instantiate_object -extra_vars $extra_vars ams_option]
    return $option_id
}


ad_proc -public ams::option::delete {
    -option_id:required
} {
    Delete an ams option

    @param option_id
} {
    db_exec_plsql ams_option_delete {}
}

ad_proc -public ams::option::name {
    -option_id:required
} {
    Delete an ams option

    @param option_id
} {
    return [db_string get_it { select option from ams_option_types where option_id = :option_id } -default {}]
}



ad_proc -public ams::ad_form::save { 
    -package_key:required
    -object_type:required
    -list_name:required
    -form_name:required
    -object_id:required
    {-copy_object_id ""}
} {
    this code saves attributes input in a form
} {
    if { [exists_and_not_null copy_object_id] } {
       ams::object_copy -from $object_id -to $copy_object_id
    }
    set list_id [ams::list::get_list_id -package_key $package_key -object_type $object_type -list_name $list_name]
    db_transaction {
	db_foreach select_elements {} {
	    set value_id [ams::widget -widget $widget -request "form_save_value" -attribute_name $attribute_name -pretty_name $pretty_name -form_name $form_name -attribute_id $attribute_id]
            ams::attribute::value_save -object_id $object_id -attribute_id $attribute_id -value_id $value_id
	}
    }
}

ad_proc -public ams::ad_form::elements { 
    -package_key:required
    -object_type:required
    -list_name:required
    {-key ""}
} {
    this code saves retrieves ad_form elements
} {
    set list_id [ams::list::get_list_id -package_key $package_key -object_type $object_type -list_name $list_name]

    set element_list ""
    if { [exists_and_not_null key] } {
        lappend element_list "$key\:key"
    }
    db_foreach select_elements {} {
	set element [ams::widget -widget $widget -request "ad_form_widget" -attribute_name $attribute_name -pretty_name $pretty_name -optional_p [string is false $required_p] -attribute_id $attribute_id]
	if { [exists_and_not_null section_heading] } {
	    lappend element [list section $section_heading]
	}
	lappend element_list $element
    }
    return $element_list
}

ad_proc -public ams::ad_form::values { 
    -package_key:required
    -object_type:required
    -list_name:required
    -form_name:required
    -object_id:required
} {
    this code populates ad_form values
} {
    set list_id [ams::list::get_list_id -package_key $package_key -object_type $object_type -list_name $list_name]
    db_transaction {
	db_foreach select_values {} {
#            ns_log notice "$widget $attribute_name $value"
	    ams::widget -widget $widget -request "form_set_value" -attribute_name $attribute_name -pretty_name $pretty_name -form_name $form_name -attribute_id $attribute_id -value $value
	}
    }
}
