ad_library {

    Support procs for the ams package

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-09-28
    @cvs-id $Id$

}



ad_proc -public ams_object_id { 
    -object_id:required
} {
    @param object_id
    Returns the revision controlled ams_object_id for the given openacs object_id. Cached.
    @return ams_object_id
} {
    return [util_memoize [list ams_object_id_not_cached -object_id $object_id]]    
}

ad_proc -private ams_object_id_not_cached {
    -object_id:required
} {
    @param object_id
    Returns the revision controlled ams_object_id for the given openacs object_id.
    @return ams_object_id
} {
    set ams_object_id [db_string select_ams_object_id {} -default {}]
    if { [exists_and_not_null ams_object_id] } {
        return $ams_object_id
    } else {
        set package_id    [ams::package_id]
        set creation_user [ad_conn user_id]
        set creation_ip   [ad_conn peeraddr]
        return [db_string create_and_select_ams_object_id {}]
    }
}

ad_proc -public ams_form {
    -package_key:required
    -object_type:required
    -list_name:required
    -form_name:required
    -object_id:required
    -return_url:required
} {
    TODO DOCUMENTATION
} {
    
    set edit_proc "ams::object::attribute::values -vars -object_id $object_id"
    set submit_proc "ams::ad_form::save -package_key $package_key -object_type $object_type -list_name $list_name -form_name $form_name -object_id $object_id"
    set after_submit_proc "ad_returnredirect $return_url"

    ad_form \
        -name $form_name \
        -form [ams::ad_form::elements -package_key $package_key -object_type $object_type -list_name $list_name -key "object_id"] \
        -edit_request $edit_proc \
        -on_submit $submit_proc \
        -after_submit $after_submit_proc

}


namespace eval ams:: {}


ad_proc -public ams::define_list { 
    -package_key:required
    -object_type:required
    -list_name:required 
    -pretty_name:required
    {-description ""}
    {-description_mime_type ""}
    {-reset_order:boolean}
    {-attributes}
} {
    TODO: Need Documentation

    @param object_type the acs object_type these attributes are to belong to
    @param attributes An array of attributes, if the attribute exists for this object this proc will make sure a duplicate is not created

    @see ams::define_attributes
} {

    # now we check to see if this list already exists
    if { ![ams::list::exists_p  -package_key $package_key -object_type $object_type -list_name $list_name] } {
        set list_id [ams::list::new -list_name $list_name \
                         -package_key $package_key \
                         -object_type $object_type \
                         -pretty_name $pretty_name \
                         -description $description \
                         -description_mime_type $description_mime_type]

    } else {
        set list_id [ams::list::get_list_id -package_key $package_key -object_type $object_type -list_name $list_name]
    }

    foreach { attribute } $attributes {
        # the attribute follows this order
        # attribute_name widget_name pretty_name pretty_plural extra_args
        set attribute_name [lindex $attribute 0]
        set widget_name    [lindex $attribute 1]
        set pretty_name    [lindex $attribute 2]
        set pretty_plural  [lindex $attribute 3]
        # we set the defaults for values that are required
        set required_p 0
        set default_name {}
        set description {}
        set default_value {}
        set context_id {}
        set options {}
        # we now check for other values
        set i 4
        while { $i < [llength $attribute] } {
            set arg [lindex $attribute $i]
            switch [lindex $arg 0] {
                required { set required_p 1 }
                default { set [lindex $arg 0] [lindex $arg 1] }
            }
            incr i
        }
        set ams_attribute_id [ams::attribute::new -object_type $object_type \
                                  -attribute_name $attribute_name \
                                  -widget_name $widget_name \
                                  -pretty_name $pretty_name \
                                  -pretty_plural $pretty_plural \
                                  -default_value $default_value \
                                  -description $description \
                                  -context_id $context_id \
                                  -options $options \
                                  -no_complain]

        if { ![exists_and_not_null ams_attribute_id] && $reset_order_p } {
            set ams_attribute_id [ams::attribute::get_ams_attribute_id -object_type $object_type -attribute_name $attribute_name]
        }
        if { [exists_and_not_null ams_attribute_id] } {
            ams::list::attribute_map -list_id $list_id \
                -ams_attribute_id $ams_attribute_id \
                -required_p $required_p
        }
    }
    ams::list::get_list_id_flush -package_key $package_key -object_type $object_type -list_name $list_name

}


ad_proc -public ams::define_attributes {
    -object_type:required
    -attributes:required
} {
    TODO: Need Documentation
    TODO: Verify the attributes passed in

    @param object_type the acs object_type these attributes are to belong to
    @param attributes An array of attributes, if the attribute exists for this object this proc will make sure a duplicate is not created

    @see ams::define_list

    <p>
    This Procedure implements a high level declarative syntax for the generation of ams_attributes
    and attribute lists. Those attribute lists can then be used to create ad_form elements, columns
    in a listbuilder array or via your own custom choosing by integrating with an ams generated
    multirow that you can use however you want in your package.
    </p>
    <p>
    <blockquote style="border: 1px dotted grey; padding: 8px; background-color: #ddddff;">
    </blockquote>

    Here is an example of the ams::define_list proc used by the contacts package:

    <pre>
    ams::define_list -package_key "contacts" \
        -object_type "ct_contact" \
        -list_name "contact_person_ae" \
        -pretty_name "The Fields used to Add/Edit a Contact Person" \
        -attributes {
            {first_names textbox {First Name(s)} {First Names} {} {} required}
            {middle_names textbox {Middle Name(s)} {Middle Names} {} {}}
            {last_name textbox {Last Name} {Last Names} {} {} required}
            {email email {Email Address} {Email Addresses} {} {}}
            {url url {Website} {Websites} {} {}}
            {home_address address {Home Address} {Home Addresses}}
            {organization_address address {Organization Address} {Organization Addresses}}
        }
    </pre>
    

    <p>Some form builder datatypes build values that do not directly correspond to database types.  When using
    the form builder directly these are converted by calls to datatype::get_property and datatype::acquire.
    When using ad_form, "to_html(property)", "to_sql(property)" and "from_sql(property)" declare the appropriate
    properties to be retrieved or set before calling code blocks that require the converted values.  The "to_sql"
    operation is performed before any on_submit, new_data or edit_data block is executed.  The "from_sql" operation
    is performed after a select_query or select_query_name query is executed.   No automatic conversion is performed
    for edit_request blocks (which manually set form values).  The "to_html" operation is performed before execution
    of a confirm template.</p>

    <p>Currently only the date and currency datatypes require these conversion operations.</p>

    <p>In the future the form builder will be enhanced so that ad_form can determine the proper conversion operation
    automatically, freeing the programmer from the need to specify them.  When this is implemented the current notation
    will be retained for backwards compatibility.</p>

} {
    set returner ""
    foreach { attribute } $attributes {
        # the attribute follows this order
        # attribute_name widget_name pretty_name pretty_plural default_value description

        ams::attribute::new -object_type $object_type \
            -attribute_name [lindex $attribute 0] \
            -widget_name [lindex $attribute 1] \
            -pretty_name [lindex $attribute 2] \
            -pretty_plural [lindex $attribute 3] \
            -default_value [lindex $attribute 4] \
            -description [lindex $attribute 5] \
            -no_complain

    }
    return $returner
}

ad_proc -public ams::package_id {} {

    TODO: Get the AMS package ID, not the connection package_id
    Get the package_id of the ams instance

    @return package_id
} {
    return [ad_conn package_id]
}


ad_proc -public ams::lang_key_encode {
    {-len "175"}
    -string:required
} {
    @param len the default value was chosen because the lang key length must be less than 200 due to a character limit on the lang_messages.message_key column and because ams depends on using some of that length for key definitions.

    @return an acs_lang encoded message key string
} {
    # we add the space at the end to prevent ellipsis at the and then remove it with string trim in order to prevent ellipsis
    return [string trim [string_truncate -len [expr $len + 1] -ellipsis " " [ad_urlencode $string]]]
}


namespace eval ams::ad_form {}

ad_proc -public ams::ad_form::save { 
    -package_key:required
    -object_type:required
    -list_name:required
    -form_name:required
    -object_id:required
} {
    this code saves attributes input in a form
} {

    set list_id [ams::list::get_list_id -package_key $package_key -object_type $object_type -list_name $list_name]

    ams::object::attribute::values -ids -array "oldvalues" -object_id $object_id
    set ams_attribute_ids [ams::list::ams_attribute_ids -list_id $list_id]
    set variables {}

    foreach ams_attribute_id $ams_attribute_ids {
        set storage_type     [ams::attribute::storage_type -ams_attribute_id $ams_attribute_id]
        set attribute_name   [ams::attribute::name -ams_attribute_id $ams_attribute_id]
        set attribute_value  [template::element::get_value $form_name $attribute_name]
        if { $storage_type == "ams_options" } {
            # we always order the options_string in the order of the option_id
            # when doing internal processing
            set attribute_value [lsort [template::element::get_values $form_name $attribute_name]]
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
#        ns_log Notice "$object_id changed vars: $variables"
        db_transaction {
            ams::object::attribute::values_flush -object_id $object_id
            set revision_id   [ams::object::revision::new -object_id $object_id]
            set ams_object_id [ams_object_id -object_id $object_id]
            foreach { ams_attribute_id attribute_value } $variables {
                ams::attribute::value::superseed -revision_id $revision_id -ams_attribute_id $ams_attribute_id -ams_object_id $ams_object_id
                if { [exists_and_not_null attribute_value] } {
                    ams::attribute::value::new -revision_id $revision_id -ams_attribute_id $ams_attribute_id -attribute_value $attribute_value
                }
            }
        }
    }
    ams::object::attribute::values -object_id $object_id
    return 1
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
        if { $required_p } {
            lappend element_list [ams::attribute::widget -ams_attribute_id $ams_attribute_id -required]
        } else {
            lappend element_list [ams::attribute::widget -ams_attribute_id $ams_attribute_id]
        }
    }
    return $element_list
}



namespace eval ams::option {}

ad_proc -public ams::option::new {
    -ams_attribute_id:required
    -option:required
    {-locale ""}
    {-sort_order ""}
} {
    Create a new ams option for an attribute

    TODO validate that the attribute is in fact one that accepts options.<br>
    TODO auto input sort order if none is supplied<br>
    TODO validate that option from the the string input from ams::lang_key_encode is equal to a pre-existing ams message if it is we need conflict resolution.

    @param ams_attribute_id
    @param option This a pretty name option
    @param locale This is the locale the option name is in
    @param sort_order if null, this option will be sorted after last previously entered option for this attribute

    @return option_id    
} {

    set lang_key "ams.option:[ams::lang_key_encode -string $option]"
    _mr en $lang_key $option
    set option $lang_key

    return [db_exec_plsql ams_option_new {}]
}


ad_proc -public ams::option::delete {
    -option_id:required
} {
    Delete an ams option

    @param option_id
} {
    db_exec_plsql ams_option_delete {}
}


ad_proc -public ams::option::map {
    {-option_map_id ""}
    -option_id:required
} {
    Map an ams option for an attribute to an option_map_id, if no value is supplied for option_map_id a new option_map_id will be created.

    @param option_map_id
    @param option_id

    @return option_map_id
} {
    return [db_exec_plsql ams_option_map {}]
}


namespace eval ams::attribute {}

ad_proc -public ams::attribute::widget {
    -ams_attribute_id:required
    {-required:boolean}
} {
    @return an ad_form encoded attribute widget
} {
    set attribute_widget [ams::attribute::widget_cached -ams_attribute_id $ams_attribute_id]

    if { [string is false $required_p] } {
        # we need to add the optional flag
        set optional_attribute_widget ""
        set i "0"
        while { $i < [llength $attribute_widget] } {
            if { $i == "0" } {
                # it is the first element in the list, so we add optional
                lappend optional_attribute_widget "[lindex $attribute_widget $i],optional"
            } else {
                # this is not the first element in the list so we simple add
                # it back to the list
                lappend optional_attribute_widget [lindex $attribute_widget $i]
            }
            incr i
        }
        set attribute_widget $optional_attribute_widget
    }

    return $attribute_widget
}

ad_proc -private ams::attribute::widget_not_cached { 
    -ams_attribute_id:required
} {
    Returns an ad_form encoded attribute widget list, as used by other procs.
    @see ams::attribute::widget_cached
} {
    db_1row select_attribute {}

    set attribute_widget "${attribute_name}:${datatype}(${widget})"

    lappend attribute_widget [list "label" "\#${pretty_name}\#"]

    if { [exists_and_not_null parameters] } {
        # the parameters are already stored in list format
        # in the database so we just add them to the list
        append attribute_widget " ${parameters}"
    }

    if { $storage_type == "ams_options" } {
        set options {}
        db_foreach select_options {} {
            lappend options [list [_ $option] [lindex $option_id]]
        }
         lappend attribute_widget [list "options" $options]
    }
    return $attribute_widget
}

ad_proc -private ams::attribute::widget_cached {
    -ams_attribute_id:required
} {
    Returns an ad_form encoded attribute widget list, as used by other procs. Cached.
    @see ams::attribute::widget_not_cached
} {
    return [util_memoize [list ams::attribute::widget_not_cached -ams_attribute_id $ams_attribute_id]]
}


ad_proc -private ams::attribute::widget_flush {
    -ams_attribute_id:required
} {
    Returns an ad_form encoded attribute widget list, as used by other procs. Flush.
    @see ams::attribute::widget_not_cached
} {
    return [util_memoize_flush [list ams::attribute::widget_not_cached -ams_attribute_id $ams_attribute_id]]
}






ad_proc -private ams::attribute::exists_p {
    -object_type:required
    -attribute_name:required
} {
    
    does an attribute with this given attribute_name for this object type exists?

    @return 1 if the attribute_name exists for this object_type and 0 if the attribute_name does not exist
} {
    set ams_attribute_id [ams::attribute::get_ams_attribute_id -object_type $object_type -attribute_name $attribute_name]
    if { [exists_and_not_null ams_attribute_id] } {
        return 1
    } else {
        return 0
    }
}

ad_proc -private ams::attribute::exists_p_flush {
    -object_type:required
    -attribute_name:required
} {
    
    does an attribute with this given attribute_name for this object type exists? Flush.

    @return ams_attribute_id if none exists then it returns blank
} {
    return [util_memoize_flush [list ams::attribute::get_ams_attribute_id_not_cached -object_type $object_type -attribute_name $attribute_name]]
}


ad_proc -private ams::attribute::get_ams_attribute_id {
    -object_type:required
    -attribute_name:required
} {
    
    return the ams_attribute_id for the given ams_attriubte_name belonging to this object_type. Cached.

    @return ams_attribute_id if none exists then it returns blank
} {

    return [util_memoize [list ams::attribute::get_ams_attribute_id_not_cached -object_type $object_type -attribute_name $attribute_name]]
}

ad_proc -private ams::attribute::get_ams_attribute_id_not_cached {
    -object_type:required
    -attribute_name:required
} {
    
    return the ams_attribute_id for the given ams_attriubte_name belonging to this object_type.

    @return ams_attribute_id if none exists then it returns blank
} {

    return [db_string get_ams_attribute_id {} -default {}]
}

ad_proc -private ams::attribute::get_ams_attribute_id_flush {
    -object_type:required
    -attribute_name:required
} {
    
    return the ams_attribute_id for the given ams_attriubte_name belonging to this object_type. Flush.

    @return ams_attribute_id if none exists then it returns blank
} {

    return [util_memoize_flush [list ams::attribute::get_ams_attribute_id_not_cached -object_type $object_type -attribute_name $attribute_name]]
}

ad_proc -public ams::attribute::new {
    {-ams_attribute_id ""}
    -object_type:required
    -attribute_name:required
    -pretty_name:required
    -pretty_plural:required
    {-default_value ""}
    {-description ""}
    -widget_name:required
    {-deprecated:boolean}
    {-context_id ""}
    {-no_complain:boolean}
    {-options}
} {
    create a new ams_attribute

    <p><dt><b>widget_name</b></dt><p>
    <dd>
       This should be a widget_name used by ams. Currently the valid widget names are:
       <pre>
       Text Widgets
       ------------

       textbox (shorthand for textbox_medium)
       textbox_small
       textbox_medium
       textbox_large

       textarea (shorthand for textarea_medium)
       textarea_small
       textarea_small_nospell
       textarea_medium
       textarea_large

       richtext (shorthand for richtext_medium)
       richtext_medium
       richtext_large


       Telephone Widgets
       -----------------

       phone (shorthand for telecom_number)
       telecom_number

       Postal Address Widgets
       ----------------------

       address (shorthand for postal_address)
       postal_address


       Multiple Choice Widgets
       -----------------------

       select             (one option allowed)
       radio              (one option allowed)
       checkbox           (multiple options allowed)
       multiselect        (multiple options allowed)
       multiselect_single (one option allowed)
       

       Other Widgets
       -------------
    
       date
       integer
       number
       email
       url
       </pre>
    </dd>
    </dl>


    @param context_id defaults to package_id
    @param no_complain silently ignore attributes that already exist.
    @param options a list of options for an ams_object that has the ams_options storage type the options will be ordered in the order of the list
    @return ams_attribute_id
} {

    switch $widget_name {
        textbox  { set widget_name "textbox_medium" }
        textarea { set widget_name "textarea_medium" }
        richtext { set widget_name "richtext_medium" }
        address  { set widget_name "postal_address" }
        phone    { set widget_name "telecom_number" }
    }
    ams::attribute::exists_p_flush -object_type $object_type -attribute_name $attribute_name
    if { [ams::attribute::exists_p -object_type $object_type -attribute_name $attribute_name] } {
        if { !$no_complain_p } {
            error "Attribute $attribute_name Already Exists" "The attribute \"$attribute_name\" already exists for object_type \"$object_type\""
        } else {
            return [ams::attribute::get_ams_attribute_id -object_type $object_type -attribute_name $attribute_name]
        }
    } else {
        set lang_key "ams.$object_type\:$attribute_name\:"
        set pretty_name_key "$lang_key\pretty_name"
        set pretty_plural_key "$lang_key\pretty_plural"
        # register lang messages
        _mr en $pretty_name_key $pretty_name
        _mr en $pretty_plural_key $pretty_plural
        
        set pretty_name $pretty_name_key
        set pretty_plural $pretty_plural_key
        

        if { [exists_and_not_null description] } {
            set description_key "$lang_key\description"
            # register lang messages
            _mr en $description_key $description
            set description $description_key
        }


        if { [empty_string_p $context_id] } {
            set context_id [ams::package_id]
        }
        set extra_vars [ns_set create]
        oacs_util::vars_to_ns_set -ns_set $extra_vars -var_list {ams_attribute_id object_type attribute_name pretty_name pretty_plural default_value description widget_name deprecated_p context_id}
        set ams_attribute_id [package_instantiate_object -extra_vars $extra_vars ams_attribute]

        ns_log Notice "$attribute_name storage type : [ams::attribute::storage_type -ams_attribute_id $ams_attribute_id]"
        if { [exists_and_not_null options] } {
            ns_log Notice "$attribute_name storage type : $options"
        }
        # now we define options for an attribute - if they are provided and the attribute accepts options
        if { [string equal [ams::attribute::storage_type -ams_attribute_id $ams_attribute_id] "ams_options"] && [exists_and_not_null options] } {
            foreach { option } $options {
                ams::option::new -ams_attribute_id $ams_attribute_id -option $option
            }
        }
        return $ams_attribute_id
    }
}


ad_proc -private ams::attribute::name_not_cached {
    -ams_attribute_id:required
} {
    get the name of an ams_attribute

    @return attribute_name

    @see ams::attribute::name
    @see ams::attribute::name_flush
} {
    return [db_string ams_attribute_name {}]
}


ad_proc -public ams::attribute::name {
    -ams_attribute_id:required
} {
    get the name of an ams_attribute. Cached.

    @return attribute pretty_name

    @see ams::attribute::name_not_cached
    @see ams::attribute::name_flush
} {
    return [util_memoize [list ams::attribute::name_not_cached -ams_attribute_id $ams_attribute_id]]
}


ad_proc -private ams::attribute::name_flush {
    -ams_attribute_id:required
} {
    Flush the storage_type of an ams_attribute.

    @return attribute pretty_name

    @see ams::attribute::name_not_cached
    @see ams::attribute::name_flush
} {
    util_memoize_flush [list ams::attribute::name_not_cached -ams_attribute_id $ams_attribute_id]
}


ad_proc -public ams::attribute::delete {
    -ams_attribute_id:required
} {
    Delete an ams attribute, and all associated attribute values

    @param option_id
} {
    db_exec_plsql ams_attribute_delete {}
}


ad_proc -private ams::attribute::storage_type_not_cached { 
    -ams_attribute_id:required
} {
    get the storage_type of an ams_attribute

    @return storage_type

    @see ams::attribute::storage_type
    @see ams::attribute::storage_type_flush
} {
    return [db_string ams_attribute_storage_type {}]
}


ad_proc -public ams::attribute::storage_type {
    -ams_attribute_id:required
} {
    get the storage_type of an ams_attribute. Cached.

    @return attribute pretty_name

    @see ams::attribute::storage_type_not_cached
    @see ams::attribute::storage_type_flush
} {
    return [util_memoize [list ams::attribute::storage_type_not_cached -ams_attribute_id $ams_attribute_id]]
}


ad_proc -private ams::attribute::storage_type_flush {
    -ams_attribute_id:required
} {
    Flush the storage_type of a cached ams_attribute.

    @return attribute pretty_name

    @see ams::attribute::storage_type_not_cached
    @see ams::attribute::storage_type_flush
} {
    util_memoize_flush [list ams::attribute::storage_type_not_cached -ams_attribute_id $ams_attribute_id]
}

ad_proc -public ams::attribute::value {
    -object_id:required
    -ams_attribute_id:required
} {
    this code returns the cached attribute value for a specific ams_attribute
} {
    set attribute_values_and_ids [ams::object::attributes::list_format -object_id $object_id]
    set attribute_value ""
    foreach attribute_value_and_id $attribute_values_and_ids {
        if { [lindex $attribute_value_and_id 0] == $ams_attribute_id } {
            set attribute_value [lindex $attribute_value_and_id 1]
        }
    }
    return $attribute_value 
}

ad_proc -public ams::attribute::value_from_name {
    -object_type:required
    -attribute_name:required
    -object_id:required
} {
    this code returns the cached attribute value for a specific ams_attribute
} {
    return [ams::attribute::value -object_id $object_id [ams::attribute::get_ams_attribute_id -object_type $object_type -attribute_name $attribute_name]]
}


namespace eval ams::attribute::value {}

ad_proc -public ams::attribute::value::new {
    -revision_id:required
    -ams_attribute_id:required
    -attribute_value:required
} {
    this code saves attributes input in a form
} {
    set storage_type [ams::attribute::storage_type -ams_attribute_id $ams_attribute_id]
    set option_map_id ""
    set address_id ""
    set number_id ""
    set time ""
    set value ""
    set value_mime_type ""

    switch $storage_type {
        telecom_number {
            # i'm not using the telecom_number plsql code here
            # since it creates unnecessary permissions by explicitly
            # granting the address creation_user admin rights, This
            # is taken care of the the ams_attribute permissions.
            #
            # plus we want this info to be the bound to the revision_id
            # not the associated address_id so we pull it from the database
            set itu_id            [template::util::telecom_number::get_property itu_id $attribute_value]
            set national_number   [template::util::telecom_number::get_property national_number $attribute_value]
            set area_city_code    [template::util::telecom_number::get_property area_city_code $attribute_value]
            set subscriber_number [template::util::telecom_number::get_property subscriber_number $attribute_value]
            set extension         [template::util::telecom_number::get_property extension $attribute_value]
            set sms_enabled_p     [template::util::telecom_number::get_property sms_enabled_p $attribute_value]
            set best_contact_time [template::util::telecom_number::get_property best_contact_time $attribute_value]
            set location          [template::util::telecom_number::get_property location $attribute_value]
            set phone_type_id     [template::util::telecom_number::get_property phone_type_id $attribute_value]

            set number_id [db_string create_telecom_number_object {}]

            db_dml create_telecom_number {}

        }

        postal_address {
            # i'm not using the postal_address plsql code here
            # since it creates unnecessary permissions by explicitly
            # granting the address creation_user admin rights, This
            # is taken care of the the ams_attribute permissions.
            #
            # plus we want this info to be the bound to the revision_id
            # not the associated address_id so we pull it from the database
            set delivery_address  [template::util::address::get_property delivery_address $attribute_value]
            set postal_code       [template::util::address::get_property postal_code $attribute_value]
            set municipality      [template::util::address::get_property municipality $attribute_value]
            set region            [template::util::address::get_property region $attribute_value]
            set country_code      [template::util::address::get_property country_code $attribute_value]
            set additional_text   [template::util::address::get_property additional_text $attribute_value]
            set postal_type       [template::util::address::get_property postal_type $attribute_value]

            set address_id [db_string create_postal_address_object {}]

            db_dml create_postal_address {}
        }

        ams_options {
            # we need to loop through the values
            # on the first option_map_id the option_map_id
            # will be set.
            foreach { option_id } $attribute_value {
                set option_map_id [ams::option::map -option_map_id $option_map_id -option_id $option_id]
            }
        }

        time {
            set value $attribute_value
        }

        value {
            set value $attribute_value
        }

        value_with_mime_type {
            set value           [template::util::richtext::get_property contents $attribute_value]
            set value_mime_type [template::util::richtext::get_property format $attribute_value]
        }
    }

    db_dml insert_attribute_value {}
}


ad_proc -public ams::attribute::value::superseed {
    -revision_id:required
    -ams_attribute_id:required
    -ams_object_id:required
} {
    superseed an attribute value
} {
    db_dml superseed_attribute_value {}
}

namespace eval ams::multirow {}

ad_proc -private ams::multirow::extend {
    -package_key:required
    -object_type:required
    -list_name:required
    -multirow:required
    -key:required
} {
    append ams_attribute_values to a multirow
} {
    set list_id [ams::list::get_list_id \
                     -package_key $package_key \
                     -object_type $object_type \
                     -list_name $list_name]


    # first we make sure all the attribute_values are efficiently cached
    # i.e. we only do one trip to the database, instead of one for
    # each object in the multirow
    set object_id_list ""
    template::multirow foreach $multirow {
        lappend object_id_list [set $key]
    }
    if { [exists_and_not_null object_id_list] } {
        ams::object::attribute::values_batch_process -object_id_list $object_id_list
    }

    # now we extend the multirow with the ams_attribute_names
    set ams_attribute_ids [ams::list::ams_attribute_ids -list_id $list_id]
    set ams_attribute_names {}
    foreach ams_attribute_id $ams_attribute_ids {
        set ams_attribute_name [ams::attribute::name -ams_attribute_id $ams_attribute_id]
        lappend ams_attribute_names $ams_attribute_name
        template::multirow extend $multirow $ams_attribute_name
    }

    # now we populate the multirow with ams_attribute_values
    template::multirow foreach $multirow {
        # first we set a null value for all ams_attribute_names
        # since the ams::object::attribute::values proc only
        # returns those ams_attribute_values that do not 
        # have a null value
        foreach ams_attribute_name ams_attribute_names {
            set [set $ams_attribute_name] {}
        }
        ams::object::attribute::values -vars -object_id [set $key]
    }
}



namespace eval ams::object {}

namespace eval ams::object::attribute {}




ad_proc -private ams::object::attribute::value_memoize {
    -object_id:required
    -ams_attribute_id:required
    -attribute_value:required
} {
    memoize an ams::object::attribute::value
} {
    if { [string is true [util_memoize_cached_p [list ams::object::attribute::values_not_cached -object_id $object_id]]] } {
        array set $object_id [util_memoize [list ams::object::attribute::values_not_cached -object_id $object_id]]        
    }
    # if a value previously existed it will be superseeded
    set ${object_id}($ams_attribute_id) $attribute_value
    util_memoize_seed [list ams::object::attribute::values_not_cached -object_id $object_id] [array get ${object_id}]
}

ad_proc -public  ams::object::attribute::value {
    -object_id:required
    -ams_attribute_id:required
} {
} {
    ams::object::attribute::values -array $object_id -object_id $object_id
    if { [info exists ${object_id}($ams_attribute_id)] } {
        return ${object_id}($ams_attribute_id)
    } else {
        return {}
    }
}

ad_proc -public  ams::object::attribute::values {
    -object_id:required
    {-ids:boolean}
    {-vars:boolean}
    {-array ""}
} {
    @param ids - if specified we will return the ams_attribute_id instead of the attribute_name
    @param array - if specified the attribute values are returned in the given array
    @param vars - if sepecified the attribute values vars are returned to the calling environment

    if neither array nor vars are specified then a list is returned
} {
    set attribute_values_list [util_memoize [list ams::object::attribute::values_not_cached -object_id $object_id]]
    if { !$ids_p } {
        set attribute_values_list_with_names ""
        foreach { key value } $attribute_values_list {
            lappend attribute_values_list_with_names [ams::attribute::name -ams_attribute_id $key]
            lappend attribute_values_list_with_names $value
        }
        set attribute_values_list $attribute_values_list_with_names
    }
    if { [exists_and_not_null array] } {
        upvar $array row
        array set row $attribute_values_list
    } elseif { $vars_p } {
        set attribute_value_info [ns_set create]
        foreach { key value } $attribute_values_list {
            ns_set put $attribute_value_info $key $value
        }
        # Now, set the variables in the caller's environment
        ad_ns_set_to_tcl_vars -level 2 $attribute_value_info
        ns_set free $attribute_value_info
    } else {
        return $attribute_values_list
    }
}


ad_proc -private ams::object::attribute::values_not_cached {
    -object_id:required
} {
} {
    ams::object::attribute::values_batch_process -object_id_list $object_id
    if { [string is true [util_memoize_cached_p [list ams::object::attribute::values_not_cached -object_id $object_id]]] } {
        return [util_memoize [list ams::object::attribute::values_not_cached -object_id $object_id]]        
    } else {
        return {}
    }
}


ad_proc -private ams::object::attribute::values_flush {
    -object_id:required
} {
} {
    return [util_memoize_flush [list ams::object::attribute::values_not_cached -object_id $object_id]]
}


ad_proc -private ams::object::attribute::values_batch_process {
    -object_id_list:required
} {
    @param object_ids a list of object_ids for which to save attributes in their respective caches.
    get these objects attribute values in a list format
} {
    set objects_to_cache ""
    foreach object_id_from_list $object_id_list {
        if { [string is false [util_memoize_cached_p [list ams::object::attribute::values -object_id $object_id_from_list]]] } {
            lappend objects_to_cache $object_id_from_list
        }
    }
    if { [exists_and_not_null objects_to_cache] } {
        set sql_object_id_list [ams::util::sqlify_list -list $objects_to_cache]
        db_foreach get_attr_values "" {
            switch [ams::attribute::storage_type -ams_attribute_id $ams_attribute_id] {
                telecom_number {
                    set attribute_value $telecom_number_string
                }
                postal_address {
                    set attribute_value $address_string
                }
                ams_options {
                    set attribute_value $options_string
                }
                time {
                    set attribute_value $time
                }
                value {
                    set attribute_value $value 
                }
                value_with_mime_type {
                    set attribute_value [list $value $value_mime_type] 
                }
            }
            set ${object_id}($ams_attribute_id) $attribute_value
        }
        foreach object_id_from_list $object_id_list {
            util_memoize_seed [list ams::object::attribute::values_not_cached -object_id $object_id_from_list] [array get ${object_id_from_list}]
        }
    }
}



namespace eval ams::object::revision {}


ad_proc -public ams::object::revision::new {
    {-package_id ""}
    -object_id:required
} {
    create a new ams_object_revision

    @return revision_id
} {
    if { [empty_string_p $package_id] } {
        set package_id [ams::package_id]
    }
    set extra_vars [ns_set create]
    oacs_util::vars_to_ns_set -ns_set $extra_vars -var_list { object_id package_id }
    set revision_id [package_instantiate_object -extra_vars $extra_vars ams_object_revision]

    return $revision_id
}












namespace eval ams::list {}

ad_proc -private ams::list::ams_attribute_ids_not_cached {
    -list_id:required
} {
    Get a list of ams_attributes.

    @return list of ams_attribute_ids, in the correct order

    @see ams::list::ams_attribute_ids
    @see ams::list::ams_attribute_ids_flush
} {
    return [db_list ams_attribute_ids {}]
}

ad_proc -private ams::list::ams_attribute_ids {
    -list_id:required
} {
    get this lists ams_attribute_ids. Cached.

    @return list of ams_attribute_ids, in the correct order

    @see ams::list::ams_attribute_ids_not_cached
    @see ams::list::ams_attribute_ids_flush
} {
    return [util_memoize [list ams::list::ams_attribute_ids_not_cached -list_id $list_id]]
}

ad_proc -private ams::list::ams_attribute_ids_flush {
    -list_id:required
} {
    Flush this lists ams_attribute_ids cache.

    @return list of ams_attribute_ids, in the correct order

    @see ams::list::ams_attribute_ids_not_cached
    @see ams::list::ams_attribute_ids
} {
    return [util_memoize_flush [list ams::list::ams_attribute_ids_not_cached -list_id $list_id]]
}



ad_proc -private ams::list::exists_p {
    -package_key:required
    -object_type:required
    -list_name:required
} {
    does an ams list like this exist?

    @return 1 if the list exists for this object_type and package_key and 0 if the does not exist
} {
    set list_id [ams::list::get_list_id -package_key $package_key -object_type $object_type -list_name $list_name]
    if { [exists_and_not_null list_id] } {
        return 1
    } else {
        return 0
    }
}


ad_proc -private ams::list::get_list_id {
    -package_key:required
    -object_type:required
    -list_name:required
} {
    
    return the list_id for the given parameters. Chached.

    @return list_id if none exists then it returns blank
} {
    return [util_memoize [list ams::list::get_list_id_not_cached -package_key $package_key -object_type $object_type -list_name $list_name]]
}

ad_proc -private ams::list::get_list_id_not_cached {
    -package_key:required
    -object_type:required
    -list_name:required
} {
    return the list_id for the given parameters

    @return list_id if none exists then it returns blank
} {

    return [db_string get_list_id {} -default {}]
}

ad_proc -private ams::list::get_list_id_flush {
    -package_key:required
    -object_type:required
    -list_name:required
} {
    
    flush the memorized list_id for the given parameters.

    @return list_id if none exists then it returns blank
} {
    return [util_memoize_flush [list ams::list::get_list_id_not_cached -package_key $package_key -object_type $object_type -list_name $list_name]]
}

ad_proc -public ams::list::new {
    {-list_id ""}
    -package_key:required
    -object_type:required
    -list_name:required
    -pretty_name:required
    {-description ""}
    {-description_mime_type "text/plain"}
    {-context_id ""}
} {
    create a new ams_group

    @return group_id
} {
    if { [empty_string_p $context_id] } {
        set context_id [ams::package_id]
    }
    if { ![exists_and_not_null description] } {
        set description_mime_type ""
    }
    set lang_key "ams.$package_key\:$object_type\:$list_name"
    _mr en $lang_key $pretty_name
    set pretty_name $lang_key

    if { [exists_and_not_null description] } {
        set lang_key "ams.$package_key\:$object_type\:$list_name\:description"
        _mr en $lang_key $description
        set description $lang_key
    }

    set extra_vars [ns_set create]
    oacs_util::vars_to_ns_set -ns_set $extra_vars -var_list { list_id package_key object_type list_name pretty_name description description_mime_type }
    set list_id [package_instantiate_object -extra_vars $extra_vars ams_list]

    return $list_id
}



ad_proc -public ams::list::attribute_map {
    -list_id:required
    -ams_attribute_id:required
    {-sort_order ""}
    {-required_p "f"}
    {-section_heading ""}
} {
    Map an ams option for an attribute to an option_map_id, if no value is supplied for option_map_id a new option_map_id will be created.

    @param sort_order if null then the attribute will be placed as the last attribute in this groups sort order

    @return option_map_id
} {
    return [db_exec_plsql ams_list_attribute_map {}]
}















namespace eval ams::util {}



ad_proc -public ams::util::sqlify_list {
    -list:required
} {
    set output_list {}
    foreach item $list {
        if { [exists_and_not_null output_list] } {
            append output_list ", "
        }
        regsub -all {'} $item {''} item
        append output_list "'$item'"
    }
    return $output_list
}
