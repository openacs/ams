ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    {orderby "name"}
}

set title "[_ ams.AMS_Lists]"
set context [list $title]

list::create \
    -name lists \
    -multirow lists \
    -key list_id \
    -row_pretty_plural "[_ ams.AMS_Lists]" \
    -checkbox_name checkbox \
    -selected_format "normal" \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -actions {
    } -bulk_actions {
    } -elements {
        edit {
            label {}
        }
        pretty_name {
            display_col pretty_name
            label "[_ ams.Pretty_Name_1]"
        }
        package_key {
            display_col package_key
            label "[_ ams.Package_Key_1]"
        }        
        list_name {
            display_col list_name
            label "[_ ams.List_Name_1]"
            link_url_eval $list_url
        }        
        object_type {
            display_col object_type
            label "[_ ams.Object_Type_1]"
            link_url_eval $object_url
        }        
    } -filters {
    } -groupby {
    } -orderby {
    } -formats {
        normal {
            label "[_ ams.Table]"
            layout table
            row {
                package_key {}
                object_type {}
                list_name {}
                pretty_name {}
            }
        }
    }


db_multirow -extend { list_url object_url } lists select_lists {
    select list_id, package_key, object_type, list_name, pretty_name
      from ams_lists
} {
    set object_url [export_vars -base object -url {object_type}]
    set list_url [export_vars -base list -url {package_key object_type list_name}]
    set pretty_name [_ $pretty_name]
}


ad_return_template
