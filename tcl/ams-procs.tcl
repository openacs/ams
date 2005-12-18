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
namespace eval ams::util {}

ad_proc -public attribute::pretty_name {
    {-attribute_id:required}
} {
    get the pretty_name of an attribute. Cached
} {
    return [lang::util::localize [util_memoize [list ::attribute::pretty_name_not_cached -attribute_id $attribute_id]]]
}

ad_proc -public attribute::pretty_name_not_cached {
    {-attribute_id:required}
} {
    get the pretty_name of an attribute
} {
    return [db_string get_pretty_name {} -default {}]
}

ad_proc -public attribute::pretty_plural {
    {-attribute_id:required}
} {
    get the pretty_plural of an attribute. Cached
} {
    return [lang::util::localize [util_memoize [list ::attribute::pretty_plural_not_cached -attribute_id $attribute_id]]]
}

ad_proc -public attribute::pretty_plural_not_cached {
    {-attribute_id:required}
} {
    get the pretty_plural of an attribute
} {
    return [db_string get_pretty_plural {} -default {}]
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

    # Update the pretty names
    set pretty_name   [lang::util::convert_to_i18n -message_key "ams_attribute_${attribute_id}_pretty_name" -text "$pretty_name"]
    set pretty_plural [lang::util::convert_to_i18n -message_key "ams_attribute_${attribute_id}_pretty_plural" -text "$pretty_plural"]
    db_dml update_pretty_names "update acs_attributes set pretty_name = :pretty_name, pretty_plural = :pretty_plural where attribute_id = :attribute_id"
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

ad_proc -public ams::package_id {
} {
TODO: Get the AMS package ID, not the connection package_id
    Get the package_id of the ams instance

@return package_id
} {
    return [ad_conn package_id]
}

ad_proc -public ams::util::edit_lang_key_url {
    -message:required
    {-package_key "ams"}
} {
} {
    if { [regsub "^${package_key}." [string trim $message "\#"] {} message_key] } {
	 set edit_url [export_vars -base "[apm_package_url_from_key "acs-lang"]admin/edit-localized-message" { { locale {[ad_conn locale]} } package_key message_key { return_url [ad_return_url] } }]
     } else {
	 set edit_url ""
     }
     return $edit_url
 }

 ad_proc -public ams::util::localize_and_sort_list_of_lists {
     {-list}
     {-position "0"}
 } {
     localize and sort a list of lists
 } {
     set localized_list [ams::util::localize_list_of_lists -list $list]
     return [ams::util::sort_list_of_lists -list $localized_list -position $position]
 }

 ad_proc -public ams::util::localize_list_of_lists {
     {-list}
 } {
     localize the elements of a list_of_lists
 } {
     set list_output [list]
     foreach item $list {
	 set item_output [list]
	 foreach part $item {
	     lappend item_output [lang::util::localize $part]
	 }
	 lappend list_output $item_output
     }
     return $list_output
 }

 ad_proc -public ams::util::sort_list_of_lists {
     {-list}
     {-position "0"}
 } {
     sort a list_of_lists
 } {
     set sort_output [list]
     foreach item $list {
	 set sort_key [string toupper [lindex $item $position]]
	 # we need to replace spaces because it prevents
	 # multi word sort keys from recieving curly
	 # brackets during the sort, which skews results
	 regsub -all " " $sort_key "_" sort_key
	 lappend sort_output [list $sort_key $item]
     }
     set sort_output [lsort $sort_output]
     set list_output [list]
     foreach item $sort_output {
	 lappend list_output [lindex $item 1]
     }
     return $list_output
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
	 set object_type [db_string get_supertype {}]
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
	 db_dml copy_object {}
     }
 }

 ad_proc -public ams::object_delete {
     {-object_id:required}
 } {
     delete and object that uses ams attributes
 } {
     return [db_dml delete_object {}]
 }

 ad_proc -public ams::attribute::get {
     -attribute_id:required
     -array:required
 } {
     Get the info on an ams_attribute
 } {
     upvar 1 $array row
     db_1row select_attribute_info {} -column_array row
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
     set existing_ams_attribute_id [db_string get_existing_ams_attribute_id {} -default {}]

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
     # db_exec_plsql attribute_value_save {}
     # This seems to be faster. Don't ask why....
     db_dml clean_up "        delete from ams_attribute_values
         where object_id = :object_id
           and attribute_id = :attribute_id"
     if {[exists_and_not_null value_id]} {
	 db_dml insert "
                insert into ams_attribute_values
                (object_id,attribute_id,value_id)
                values
                (:object_id,:attribute_id,:value_id)"
     }
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

     set option_id [db_string get_option_id { select option_id from ams_option_types where option = :option and attribute_id = :attribute_id } -default {}]

     if { $option_id == "" } {

	 set option_id [db_nextval acs_object_id_seq]
	 set pretty_name [lang::util::convert_to_i18n -message_key "ams_option_${option_id}" -text "$option"]
	 set extra_vars [ns_set create]
	 oacs_util::vars_to_ns_set -ns_set $extra_vars -var_list {option_id attribute_id option sort_order deprecated_p pretty_name}
	 set option_id [package_instantiate_object -extra_vars $extra_vars ams_option]
	 
	 # For whatever the reason it does not insert the pretty_name,
	 # let's do it manually then...
	 db_dml update_pretty_name  "update acs_objects set title = :pretty_name where object_id = :option_id"
     }
    
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
    return [lang::util::localize [db_string get_option {} -default {}]]
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
    {-list_name ""}
    {-list_names ""}
    {-key ""}
} {
    This code saves retrieves ad_form elements, it recieves list_name or list_names switch, if both are provided
    then it would use list_names.

    @param package_key      The package_key of the list_id.
    @param object_type      The object_type of the list_id.
    @param list_name        The list_name to get the list_id. Either this or list_names must be provided.
    @param list_names       A list of list_names to get the list_ids from. Either this or list_name must be provided.
    @param key              The key element to use in the form.
} {
    set list_ids [list]
    if { [empty_string_p $list_names] && [empty_string_p $list_name] } {
	ad_return_complaint 1 "[_ ams.you_must_provide_list_name]"
	ad_script_abort
    }

    if { [empty_string_p $list_names] && ![empty_string_p $list_name] } {
	set list_names $list_name
    }

    foreach l_name $list_names {
	set list_id [ams::list::get_list_id -package_key $package_key -object_type $object_type -list_name $l_name]
	if {![empty_string_p $list_id]} {
	    lappend list_ids $list_id
	}
    }
    
    # To use in the query
    set list_ids [template::util::tcl_to_sql_list $list_ids]
    set element_list ""
    if { [exists_and_not_null key] } {
        lappend element_list "$key\:key"
    }

    # Control list to know which attributes are already in the
    # elements list so we don't en up with duplicates
    set control_list [list]
    
    # If we do not have a list_id then don't bother to try and get any attributes...
    if {[string eq "" $list_ids]} {
        set all_attributes [list]
    } else {
        set all_attributes [db_list_of_lists select_elements " "]
    }

    foreach attribute $all_attributes {
	set attribute_id [lindex $attribute 0]
	if { [string equal [lsearch $control_list $attribute_id] "-1"] } {
	    lappend control_list $attribute_id
	    set required_p      [lindex $attribute 1]
	    set section_heading [lindex $attribute 2]
	    set attribute_name  [lindex $attribute 3]
	    set pretty_name     [lindex $attribute 4]
	    set widget          [lindex $attribute 5]

	    set element [ams::widget \
			     -widget $widget \
			     -request "ad_form_widget" \
			     -attribute_name $attribute_name \
			     -pretty_name $pretty_name \
			     -optional_p [string is false $required_p] -attribute_id $attribute_id]

	    if { [exists_and_not_null section_heading] } {
		lappend element [list section $section_heading]
	    }
	    lappend element_list $element
	}
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
    db_foreach select_values {} {
        ams::widget -widget $widget -request "form_set_value" -attribute_name $attribute_name -pretty_name $pretty_name -form_name $form_name -attribute_id $attribute_id -value $value
    }
}

ad_proc -public ams::values {
    -package_key:required
    -object_type:required
    {-list_name ""}
    {-list_names ""}
    -object_id:required
    {-format "text"}
    {-locale ""}
} {
    This returns a list with the first element as the pretty_attribute name 
    and the second the value. Cached
} {
    return [util_memoize [list ams::values_not_cached \
			      -package_key $package_key \
			      -object_type $object_type \
			      -list_name $list_name \
			      -list_names $list_names \
			      -object_id $object_id \
			      -format $format \
			      -locale $locale]]
}


ad_proc -public ams::values_not_cached {
    -package_key:required
    -object_type:required
    {-list_name ""}
    {-list_names ""}
    -object_id:required
    {-format "text"}
    {-locale ""}
} {
    this returns a list with the first element as the pretty_attribute name and the second the value
} {
    if { $format != "html" } {
        set format "text"
    }
    if { [empty_string_p $list_names] && [empty_string_p $list_name] } {
	ad_return_complaint 1 "[_ ams.you_must_provide_list_name]"
	ad_script_abort
    }

    if { [empty_string_p $list_names] && ![empty_string_p $list_name] } {
	set list_names $list_name
    }

    foreach l_name $list_names {
	set list_id [ams::list::get_list_id -package_key $package_key -object_type $object_type -list_name $l_name]
	if {![empty_string_p $list_id]} {
	    lappend list_ids $list_id
	}
    }

    # To use in the query
    set list_ids [template::util::tcl_to_sql_list $list_ids]

    if { [exists_and_not_null list_ids] } {
        set values [list]
        set heading ""
	
	# Control list to know which attributes are already in the
	# elements list so we don't en up with duplicates
	set control_list [list]
	
	set all_attributes [db_list_of_lists select_values " "]
	
        foreach attribute $all_attributes {
	    set attribute_id [lindex $attribute 0]
	    if { [string equal [lsearch $control_list $attribute_id] "-1"] } {
		lappend control_list $attribute_id
		set section_heading [lindex $attribute 1]
		set attribute_name  [lindex $attribute 2]
		set pretty_name     [lindex $attribute 3]
		set widget          [lindex $attribute 4]
		set value           [lindex $attribute 5]
		
		set val [list]
		if { [regexp "\{text/.*\}" $value value_format] } {
		    lappend val [lindex $value_format 0]
		    lappend val [list [string range $value [expr [string length $value_format] + 1] [string length $value]]]
		} else {
		    set val $value
		}
	    
		if { [exists_and_not_null section_heading] } {
		    set heading $section_heading
		}
		if { [exists_and_not_null value] } {
		    lappend values $heading $attribute_name $pretty_name [ams::widget \
									      -widget $widget \
									      -request "value_${format}" \
									      -attribute_name $attribute_name \
									      -attribute_id $attribute_id \
									      -value $value \
									      -locale $locale]

		    ns_log Debug "$attribute_name ($attribute_id):: $value"
		}

		ns_log Debug "$attribute_name ($attribute_id):: $value"
	    }
	}
        return $values
    } else {
        return [list]
    }
}


ad_proc -public ams::value {
    -object_id:required
    {-attribute_id ""}
    {-attribute_name ""}
    {-format "html"}
    {-locale ""}
} {
    Return the value of an attribute for a certain object. You can
    provide either the attribute_id or the attribute_name. Cached.
    
    @param object_id The object for which the value is stored
    @param attribute_id The attribute_id of the attribute for which the value is retrieved
    @param attribute_name Alternatively the attribute_name for the attribute
    @return
    @error
} {
    return [util_memoize [list ams::value_not_cached \
			      -object_id $object_id \
			      -attribute_id $attribute_id \
			      -attribute_name $attribute_name \
			      -format $format \
			      -locale $locale]]
}

ad_proc -public ams::value_not_cached {
    -object_id:required
    -attribute_id
    -attribute_name
    {-format "html"}
    {-locale ""}
} {
    Return the value of an attribute for a certain object. You can
    provide either the attribute_id or the attribute_name
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-07-22
    
    @param object_id The object for which the value is stored
    
    @param attribute_id The attribute_id of the attribute for which the value is retrieved
    
    @param attribute_name Alternatively the attribute_name for the attribute
    
    @return
    
    @error
} {
    if {[exists_and_not_null attribute_id]} {
	set where_clause "and aa.attribute_id = :attribute_id"
    } else {
	set where_clause "and aa.attribute_name = :attribute_name"
    }
    
    if {[db_0or1row select_value {}]} {
	return [ams::widget -widget $widget -request "value_${format}" -attribute_name $attribute_name -attribute_id $attribute_id -value $value -locale $locale]
    } else {
	return ""
    }
}

