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
    set pretty_name   [lang::util::convert_to_i18n -message_key "ams_attribute.${object_type}.${attribute_name}.pretty_name" -text "$pretty_name"]
    set pretty_plural [lang::util::convert_to_i18n -message_key "ams_attribute.${object_type}.${attribute_name}.pretty_plural" -text "$pretty_plural"]

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
     db_1row get_object_data { select object_type, attribute_name from ams_attributes where attribute_id = :attribute_id }

     set option_id [db_string get_option_id { select option_id from ams_option_types where option = :option and attribute_id = :attribute_id } -default {}]

     if { $option_id == "" } {

	 set option_id [db_nextval acs_object_id_seq]
	 set pretty_name [lang::util::convert_to_i18n -message_key "${attribute_name}_$option_id" -text "$option"]
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
    db_foreach select_values {} {
        ams::widget -widget $widget -request "form_set_value" -attribute_name $attribute_name -pretty_name $pretty_name -form_name $form_name -attribute_id $attribute_id -value $value
    }
}

ad_proc -public ams::values {
    -package_key:required
    -object_type:required
    -list_name:required
    -object_id:required
    {-format "text"}
    {-locale ""}
} {
    this returns a list with the first element as the pretty_attribute name and the second the value
} {
    if { $format != "html" } {
        set format "text"
    }
    set list_id [ams::list::get_list_id -package_key $package_key -object_type $object_type -list_name $list_name]
    if { [exists_and_not_null list_id] } {
        set values [list]
        set heading ""
        db_foreach select_values {} {
            if { [exists_and_not_null section_heading] } {
                set heading $section_heading
            }
            if { [exists_and_not_null value] } {
                lappend values $heading $attribute_name $pretty_name [ams::widget -widget $widget -request "value_${format}" -attribute_name $attribute_name -attribute_id $attribute_id -value $value -locale $locale]
            }
        }
        return $values
    } else {
        return [list]
    }
}

ad_proc -public ams::value {
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

ad_proc -public ams::attribute::save_text {
    -object_id:required
    {-attribute_id ""}
    {-attribute_name ""}
    {-object_type ""}
    {-format "text/plain"}
    -value
} {
    Save the value of an AMS text attribute for an object.
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-07-22
    
    @param object_id The object for which the value is stored
    
    @param attribute_id The attribute_id of the attribute for which the value is retrieved
    
    @param attribute_name Alternatively the attribute_name for the attribute
    
    @return
    
    @error
} {
    if {[exists_and_not_null value]} {
	if {[empty_string_p $attribute_id]} {
	    set attribute_id [attribute::id \
				  -object_type "$object_type" -attribute_name "$attribute_name"]
	}
	if {[exists_and_not_null attribute_id]} {
	    set value_id [ams::util::text_save \
			      -text $value \
			      -text_format "text/plain"]
	    ams::attribute::value_save -object_id $object_id -attribute_id $attribute_id -value_id $value_id
	}
    }
}

ad_proc -public ams::attribute::save_mc {
    -object_id:required
    {-attribute_id ""}
    {-attribute_name ""}
    {-object_type ""}
    -value
    {-format "text/plain"}
} {
    Save the value of an AMS multiple choice attribute like "select",
    "radio"  for an object.
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-07-22
    
    @param object_id The object for which the value is stored
    
    @param attribute_id The attribute_id of the attribute for which the value is retrieved
    
    @param attribute_name Alternatively the attribute_name for the attribute

    @return
    
    @error
} {
    if {[exists_and_not_null value]} {
	# map values if corresponding mapping-function
	# exists
	
	set proc "map_$attribute"
	
	if {[llength [info procs $proc]] == 1} {
	    if {[exists_and_not_null value]} {
		if {[catch {set value [eval $proc {$value}]} err]} {
		    append error_string "Contact \#$contact_count ($first_names $last_name): $err<br>"
		}
	    }
	}
    }
    
    if {[exists_and_not_null value]} {

	if {[empty_string_p $attribute_id]} {
	    set attribute_id [attribute::id \
				  -object_type "$object_type" -attribute_name "$attribute_name"]
	}

	switch $value {
	    "TRUE" {set value "t" }
	    "FALSE" {set value "f" }
	    default {set value "#acs-translations.organization_[set attribute]_$value#"}
	}
	set option_id [db_string get_option {select option_id from ams_option_types where attribute_id = :attribute_id and option = :value} \
			   -default {}]

	# Create the option if it no already existed.
	if {![exists_and_not_null option_id]} {
	    set option_id [ams::option::new \
			       -attribute_id $attribute_id \
			       -option $value]
	    ns_log notice "...... CREATED OPTION $option_id: $value"
	}
	
	# Save the value using the option_id
	set value_id [ams::util::options_save \
			  -options $option_id]
	ams::attribute::value_save -object_id $object_id -attribute_id $attribute_id -value_id $value_id
    }
}