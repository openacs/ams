ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    {orderby "name"}
}

set title "AMS Lists"
set context [list $title]

list::create \
    -name lists \
    -multirow lists \
    -key list_id \
    -row_pretty_plural "AMS Lists" \
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
            label "Pretty Name"
        }
        package_key {
            display_col package_key
            label "Package Key"
        }        
        list_name {
            display_col list_name
            label "List Name"
            link_url_eval $list_url
        }        
        object_type {
            display_col object_type
            label "Object Type"
            link_url_eval $object_url
        }        
    } -filters {
    } -groupby {
    } -orderby {
    } -formats {
        normal {
            label "Table"
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
    set object_url "list?[export_vars -url {object_type}]"
    set list_url "list?[export_vars -url {package_key object_type list_name}]"
    set pretty_name [_ $pretty_name]
}


ad_return_template
