ad_page_contract {
    
    This page lets users manage ams lists

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    package_key:notnull
    object_type:notnull
    list_name:notnull
    groupby:optional
    orderby:optional
    {format "normal"}
    {status "normal"}
}

set list_id [ams::list::get_list_id -package_key $package_key -object_type $object_type -list_name $list_name]
ams::list::get -list_id $list_id -array "list_info"
set title [_ $list_info(pretty_name)]
set context [list [list lists Lists] $title]

list::create \
    -name mapped_attributes \
    -multirow mapped_attributes \
    -key ams_attribute_id \
    -row_pretty_plural "Mapped Attributes" \
    -checkbox_name checkbox \
    -selected_format $format \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
    } -actions {
    } -bulk_actions {
	"Answer Required" "list-attributes-required" "Require an answer from the checked attributes"
	"Answer Optional" "list-attributes-optional" "An answer from the checked attributes is optional"
	"Unmap" "list-attributes-unmap" "Unmap check attributes"
	"Update Ordering" "list-order-update" "Update ordering from values in list"
    } -bulk_action_export_vars { 
        list_id
    } -elements {
        attribute_name {
            label "Attribute"
            display_col attribute_name
        }
        pretty_name {
            label "Pretty Name"
            display_col pretty_name
            link_url_eval $attribute_url
        }
        widget {
            label "Widget"
            display_col widget
            link_url_eval widgets
        }
        action {
            label "Action"
            display_template {
                <a href="list-attributes-unmap?list_id=$list_id&ams_attribute_id=@mapped_attributes.ams_attribute_id@" class="button">Unmap</a>
            }
        }
        answer {
            label "Required"
            display_template {
                <if @mapped_attributes.required_p@>
                <a href="list-attributes-optional?list_id=$list_id&ams_attribute_id=@mapped_attributes.ams_attribute_id@"><img src="/resources/acs-subsite/checkboxchecked.gif" title="Required" border="0"></a>
                </if>
                <else>
                <a href="list-attributes-required?list_id=$list_id&ams_attribute_id=@mapped_attributes.ams_attribute_id@"><img src="/resources/acs-subsite/checkbox.gif" title="Optional" border="0"></a>
                </else>
            }
        }
        sort_order {
            label "Ordering"
            display_template {
                <input name="sort_key.@mapped_attributes.ams_attribute_id@" value="@mapped_attributes.sort_order_key@" size="4">
            }
        }
    } -filters {
    } -groupby {
    } -orderby {
    } -formats {
        normal {
            label "Table"
            layout table
            row {
                checkbox {}
                pretty_name {}
                sort_order {}
                answer {}
                action {}
            }
        }
    }


#                  Table "public.ams_lists"
#        Column         |          Type           | Modifiers 
#-----------------------+-------------------------+-----------
# list_id               | integer                 | not null
# package_key           | character varying(100)  | not null
# object_type           | character varying(1000) | not null
# list_name             | character varying(100)  | not null
# pretty_name           | character varying(200)  | not null
# description           | character varying(200)  | 
# description_mime_type | character varying(200)  | 


# Table "public.ams_list_attribute_map"
#      Column      |          Type          | Modifiers 
#------------------+------------------------+-----------
# list_id          | integer                | not null
# ams_attribute_id | integer                | not null
# sort_order       | integer                | not null
# required_p       | boolean                | not null
# section_heading  | character varying(200) | 


set sort_order_count 10

db_multirow -extend { sort_order_key attribute_url } mapped_attributes select_mapped_attributes {
        select alam.required_p,
               alam.section_heading,
               ams.ams_attribute_id,
               ams.widget_name,
               ams.deprecated_p,
               acs.attribute_name,
               acs.pretty_name,
               acs.pretty_plural,
               acs.object_type
          from ams_list_attribute_map alam,
               ams_attributes ams,
               acs_attributes acs
         where alam.list_id = :list_id
           and alam.ams_attribute_id = ams.ams_attribute_id
           and ams.attribute_id = acs.attribute_id
         order by alam.sort_order
} {
    set pretty_name [_ $pretty_name]
    set attribute_url "attribute?[export_vars -url {ams_attribute_id}]"
    set sort_order_key $sort_order_count
    incr sort_order_count 10
}


#----------------------------------------------------------------------
# List builder
#----------------------------------------------------------------------





list::create \
    -name unmapped_attributes \
    -multirow unmapped_attributes \
    -key ams_attribute_id \
    -row_pretty_plural "Unmapped Attributes" \
    -checkbox_name checkbox \
    -selected_format "normal" \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
    } -actions {
    } -bulk_actions {
	"Map" "list-attributes-map" "Map the selected attributes"
    } -bulk_action_export_vars { 
        list_id
    } -elements {
        attribute_name {
            label "Attribute"
            display_col attribute_name
        }
        pretty_name {
            label "Pretty Name"
            display_col pretty_name
            link_url_eval $attribute_url
        }
        widget {
            label "Widget"
            display_col widget_name
            link_url_eval widgets
        }
        action {
            label "Action"
            display_template {
                <a href="list-attributes-map?list_id=$list_id&ams_attribute_id=@unmapped_attributes.ams_attribute_id@" class="button">Map</a>
            }
        }
    } -filters {
    } -groupby {
    } -orderby {
    } -formats {
        normal {
            label "Table"
            layout table
            row {
                checkbox {}
                pretty_name {}
                widget {}
                action {}
            }
        }
    }



# This query will override the ad_page_contract value entry_id

db_multirow -extend { attribute_url } -unclobber unmapped_attributes get_unmapped_attributes {
        select ams.ams_attribute_id,
               ams.widget_name,
               ams.deprecated_p,
               acs.attribute_name,
               acs.pretty_name,
               acs.pretty_plural,
               acs.object_type
          from ams_attributes ams,
               acs_attributes acs
         where ams.ams_attribute_id not in ( select alam.ams_attribute_id from ams_list_attribute_map alam where alam.list_id = :list_id )
           and ams.attribute_id = acs.attribute_id
} {
    set pretty_name [_ $pretty_name]
    set attribute_url "attribute?[export_vars -url {ams_attribute_id}]"

}



ad_return_template





