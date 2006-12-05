ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
    {object_type:notnull}
    orderby:optional
}

acs_object_type::get -object_type $object_type -array "object_info"

set title "$object_info(pretty_name)"
set context [list [list objects Objects] $title]


list::create \
    -name object_attributes \
    -multirow object_attributes \
    -key attribute_name \
    -row_pretty_plural "[_ ams.AMS_Attributes]" \
    -checkbox_name checkbox \
    -selected_format "normal" \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
        object_type
    } -actions [list "[_ acs-kernel.common_Add]" "attribute-add?object_type=$object_type" "[_ ams.Add_an_AMS_Attribute]"] \
    -bulk_actions {
    } -elements {
        edit {
            label {}
        }
        pretty_name {
            display_col pretty_name
            label "[_ ams.Pretty_Name_1]"
            link_url_eval $ams_attribute_url
        }
        attribute_name {
            display_col attribute_name
            label "[_ ams.Attribute_Name]"
        }
        widget {
            label "[_ ams.Widget_1]"
            display_template {
                <if @object_attributes.widget@ nil><a href="attribute-add?object_type=@object_type@&attribute_name=@object_attributes.attribute_name@" class="button">[_ ams.Define_Widget]</a></if><else>@object_attributes.widget@</else>
            }
        }
    } -filters {
        object_type {}
    } -groupby {
    } -orderby {
        default_value default_sort,asc
        default_sort {
            label default_sort
            multirow_cols {ams_attribute_p pretty_name attribute_name}
        }
        pretty_name {
            label pretty_name
            multirow_cols {ams_attribute_p pretty_name attribute_name}
        }
        attribute_name {
            label attribute_name
            multirow_cols {ams_attribute_p attribute_name pretty_name}
        }
        widget {
            label widget_name
            multirow_cols {ams_attribute_p widget pretty_name attribute_name}
        }
    } -formats {
        normal {
            label "[_ ams.Table]"
            layout table
            row {
                pretty_name {}
                attribute_name {}
                widget {}
            }
        }
    }


db_multirow -extend { ams_attribute_url ams_attribute_p } object_attributes select_object_attributes {
    select attribute_name,
           pretty_name,
           pretty_plural,
           attribute_id,
           widget
      from ams_attributes
     where object_type = :object_type
     order by upper(pretty_name)
} {
    if { [exists_and_not_null ams_attribute_id] } { set ams_attribute_p 1 } else { set ams_attribute_p 0 }
    set ams_attribute_url "attribute?attribute_id=$attribute_id"
    if { [lang::message::message_exists_p en_US $pretty_name] } {
        set pretty_name [_ $pretty_name]
    }
}


































# AMS Lists associated with this object type

list::create \
    -name ams_lists \
    -multirow ams_lists \
    -key list_id \
    -row_pretty_plural "Attributes not managed by AMS" \
    -checkbox_name checkbox \
    -selected_format "normal" \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
        variable
    } -actions [list "Add" "list-add?object_type=$object_type" "Add an AMS List"] \
    -bulk_actions {
    } -elements {
        package_key {
            label "Package Key"
            display_col package_key
        }
        object_type {
            label "Object Type"
            display_col object_type
        }
        list_name {
            label "List Name"
            display_col list_name
            link_url_eval $list_link
        }
        pretty_name {
            display_col pretty_name
            label "Pretty Name"
        }
        description {
            display_col description_html;noquote
            label "Description"
        }
        actions {
            label ""
            display_template {
                <a href="" class="button"></a>
            }
        }
    } -filters {
        object_type {}
    } -groupby {
    } -orderby {
    } -formats {
        normal {
            label "Table"
            layout table
            row {
                package_key {}
                list_name {}
                pretty_name {}
                description {}
            }
        }
    }


db_multirow -extend { description_html list_link } ams_lists select_ams_lists {
    select *
      from ams_lists
     where object_type = :object_type
} {
    set pretty_name [_ $pretty_name]
    set list_link "list?[export_vars -url {package_key object_type list_name}]"
    set description_html [ad_html_text_convert -from $description_mime_type -to "text/html" -truncate_len "175" $description]
}






ad_return_template
