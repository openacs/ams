ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
}

ad_proc -public ams_ad_form_save {
    {-name}
    {-list_id}
    {-object_id}
} {
    this code saves attributes input in a form
} {
    ams::object::attribute::values -array oldvalues $object_id
    set ams_attribute_ids [ams::list::ams_attribute_ids $list_id]
    foreach ams_attribute_id $ams_attribute_ids {
        set storage_type     [ams::attribute::storage_type $ams_attribute_id]
        set attribute_name   [ams::attribute::name $ams_attribute_id]
        set attribute_value  [template::element::get_value $name $attribute_name]
        if { $storage_type == "ams_options" } {
            set attribute_value [template::element::get_values $name $attribute_name]
        }
        if { [info exists oldvalues($ams_attribute_id)] } {
            if { $attribute_value != $oldvalues($ams_attribute_id) } {
                lappend variables $ams_attribute_id $attribute_value
            }
        } else {
            if { [exists_and_not_null attribute_value] } {
                lappend variables $ams_attribute_id $attribute_value
            }
        }
    }
    if { [exists_and_not_null variables] } {
        ns_log Notice "$object_id changed vars: $variables"
#        ams_attributes_save $object_id $variables
    }
    db_transaction {
        ams::object::attribute::values_flush $object_id
        set revision_id   [ams::object::revision::new $object_id]
        set ams_object_id [ams_object_id $object_id]
        ams::attribute::value::superseed $revision_id $ams_attribute_id $ams_object_id
        foreach { ams_attribute_id attribute_value } $variables {
            if { [exists_and_not_null attribute_value] } {
                ams::attribute::value::new $revision_id $ams_attribute_id $attribute_value
            }
        }
    }
    ams::object::attribute::values $object_id
    return 1
}

ad_proc -public ams_attributes_save {
    object_id
    attribute_value_list
} {
    this code saves attributes input in a form
} {
    db_transaction {
        set revision_id   [ams::object::revision::new $object_id]
        set ams_object_id [ams_object_id $object_id]
        foreach attribute_id_value $attribute_value_list {
            # TODO find those that need to be updated (since its cached) and put them in attribute_values_to_update
            set ams_attribute_id     [lindex $attribute_id_value 0]
            set new_attribute_value  [lindex $attribute_id_value 1]
            set old_attribute_value  [ams::attribute::value $object_id $ams_attribute_id]
            ns_log Notice "AMS: $ams_attribute_id , old: $old_attribute_value , new: $new_attribute_value"
            if { [string compare $old_attribute_value $new_attribute_value] != "0" } {
#                ams::attribute::value::superseed $revision_id $ams_attribute_id $ams_object_id
            } else {
                if { [exists_and_not_null new_attribute_value] } {
                    ams::attribute::value::new $revision_id $ams_attribute_id $attribute_value
                } 
            }
        }
    }
    ams::object::attribute::values_flush $object_id
    ams::object::attribute::values $object_id
}




























ad_proc -private ams_form {
    {-name}
    {-key}
    {-list_id}
    {-return_message}
    {-return_url}
} {
} {

    ad_form \
        -name $name \
        -form [ams::ad_form::elements_from_list_id -key $key $list_id] \
        -edit_request {
            ams::object::attribute::values -names -varenv $object_id
        } -validate {
        } -on_submit {
            ams_ad_form_save -name $name -list_id $list_id -object_id $object_id
        } -after_submit {
            if { [exists_and_not_null $message] } {
                ad_returnredirect $message $return_url
            } else {
                ad_returnredirect $return_url
            }
        }
}


set object_id 1931


set title "Attribute Management System"
set context {}

ad_form -name entry \
    -form [ams::ad_form::elements_from_list_id -key object_id 1935]

ad_form -extend -name entry \
    -new_request {
    } -edit_request {
        ams::object::attribute::values -names -varenv $object_id
    } -validate {
    } -on_submit {
        ams_ad_form_save -name entry -list_id 1935 -object_id $object_id
    } -after_submit {
        if { ![exists_and_not_null return_url] } {
            set return_url "./"
        }
#        ad_returnredirect -message "[acs_object_name $object_id] Updated" $return_url
#        ad_script_abort
#        set attr_list [ams_ad_form_save -name entry -list_id 1935 -object_id $object_id]

    }

#ams::object::attributes::flush $object_id
#set attr_list ""
set attr_list [ams::object::attribute::values -names $object_id]
#set attr_list $fred(last_name)

ad_return_template
