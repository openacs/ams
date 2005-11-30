ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
}

# MS (2005-05-29): Removed a ton of code that is unnecessary
set title "[_ ams.lt_Attribute_Management_]"
set context {}
set package_id [ad_conn package_id]
set parameters_url [export_vars -base "/shared/parameters" {package_id {return_url [ad_return_url]}}]
ad_return_template
