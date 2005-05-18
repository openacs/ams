ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    list_id:integer,notnull
}


ams::list::get -list_id $list_id -array list_info
set list_name $list_info(list_name)
set object_type $list_info(object_type)
set package_key $list_info(package_key)
set pretty_name [_ $list_info(pretty_name)]

set title "Form Preview"
set context [list [list lists Lists] [list [export_vars -base "list" -url {package_key object_type list_name}] $pretty_name] $title]
#ams::widget_options -attribute_id "130"
ad_form -name form_preview \
    -form [ams::ad_form::elements -package_key $package_key \
               -object_type $object_type \
               -list_name $list_name -key list_id] \
    -edit_request {
#        ams::ad_form::values -package_key $package_key \
#            -object_type $object_type \
#            -list_name $list_name \
#            -form_name "form_preview" \
#            -object_id $list_id
    } -on_submit {
#        ams::ad_form::save -package_key $package_key \
#            -object_type $object_type \
#            -list_name $list_name \
#            -form_name "form_preview" \
#            -object_id $list_id
    } -after_submit {
        ad_returnredirect -message "Submitting the preview form does not save any information." [export_vars -base "list" -url {list_name object_type package_key}]
    }


# Once done comment out the error line
# ad_return_error "You need to specify and valid object id in the packages/ams/www/index.tcl file" "Once done comment out this line."


 
#set package_key      "ams"
#set object_type      "ams_list"
#set list_name        "ams_list_demo3"
#set pretty_name      "The Fields used to Add/Edit a Contact Person"
#
#ams::define_list -package_key $package_key \
#    -object_type $object_type \
#     -list_name $list_name \
#    -pretty_name $pretty_name \
#    -attributes {
#        {first_names textbox {First Name(s)} {First Names} required {description {this is my description of first names}}}
#        {middle_names textbox {Middle Name(s)} {Middle Names}}
#        {last_name textbox {Last Name} {Last Names} required}
#        {email email {Email Address} {Email Addresses}}
#        {url url {Website} {Websites}}
#         {home_address address {Home Address} {Home Addresses}}
#        {organization_address address {Organization Address} {Organization Addresses}}
#        {home_phone telecom_number {Home Phone} {Home Phones}}
#        {gender radio {Gender} {Genders} {options {{Male} {Female}}} required}
#    }
#
#set object_id [ams::list::get_list_id \
#                   -package_key $package_key \
#                    -object_type $object_type \
#                   -list_name $list_name]
#set object_id "452"
##ad_form -name entry \
##    -form [ams::ad_form::elements -package_key $package_key \
##               -object_type $object_type \
##               -list_name $list_name \
##              -key "object_id"] \
#    -edit_request {
#        ams::object::attribute::values -vars -object_id $object_id
#    } -on_submit {
#        ams::ad_form::save -package_key $package_key \
#            -object_type $object_type \
#            -list_name $list_name \
#            -form_name "entry" \
#            -object_id $object_id
#    } -after_submit {
#        if { ![exists_and_not_null return_url] } {
#            set return_url "./"
#        }
#    }
#
 
#ams_form -package_key $package_key \
#    -object_type $object_type \
#    -list_name $list_name \
#    -form_name "entry" \
#    -object_id $object_id \
#    -return_url "./"
#
# set attr_list [ams::object::attribute::values_flush -object_id $object_id]
#set attr_list [ams::object::attribute::values -object_id $object_id]
#
#
#db_multirow lists get_list { select list_id, pretty_name from ams_lists }
#
#ams::multirow::extend \
#    -package_key $package_key \
#     -object_type $object_type \
#    -list_name $list_name \
#    -multirow "lists" \
#    -key "list_id"
##
##template::multirow extend lists [list first_names last_name home_address first_names]
##
##
#set key_id "list_id"
#template::multirow foreach lists {
#    set object_id [set $key_id]
#    ams::object::attribute::values -vars -object_id $object_id
#}
## set attr_list $rowcount
#template::multirow foreach lists {
#    ns_log Notice "$first_names $last_name $home_address"
#}


#set fred ""

#foreach { arg_parser procedure } [info procs "::ams::widget::*"] {
#    regsub "::ams::widget::" $procedure "" widget
#    if { [exists_and_not_null widget] } {
#	lappend fred $widget
#    }
#}
#set fred "date"
#set fred [info procs "::ams::widget::${fred}"]

ad_return_template
