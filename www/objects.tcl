ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    {orderby "name"}
}

set title "[_ ams.Objects]"
set context [list $title]

list::create \
    -name object_types \
    -multirow object_types \
    -key object_type \
    -row_pretty_plural "[_ ams.Object_Types]" \
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
            link_url_eval $object_attributes_url
        }
        object_type {
            display_col object_type
            label "[_ ams.Object_Type_1]"
            link_url_eval $object_attributes_url
        }        
    } -filters {
    } -groupby {
    } -orderby {
    } -formats {
        normal {
            label "[_ ams.Table]"
            layout table
            row {
                pretty_name {}
                object_type {}
            }
        }
    }


db_multirow -extend { object_attributes_url } object_types select_object_types {
    select object_type,
           pretty_name
      from acs_object_types
     order by lower(pretty_name)
} {
    set object_attributes_url "object?object_type=$object_type"
}


ad_return_template
