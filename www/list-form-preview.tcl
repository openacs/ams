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

set title "[_ ams.Form_Preview]"
set context [list [list lists Lists] [list [export_vars -base "list" -url {package_key object_type list_name}] $pretty_name] $title]
ad_form -name form_preview \
    -form [ams::ad_form::elements -package_key $package_key \
               -object_type $object_type \
               -list_name $list_name -key list_id] \
    -edit_request {
    } -on_submit {
    } -after_submit {
        ad_returnredirect -message "[_ ams.lt_Submitting_the_previe]" [export_vars -base "list" -url {list_name object_type package_key}]
    }

ad_return_template
