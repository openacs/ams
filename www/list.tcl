ad_page_contract {
    
    This page lets users manage ams lists

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    package_key:notnull
    object_type:notnull
    list_name:notnull
    {pretty_name ""}
    {description ""}
    groupby:optional
    orderby:optional
    {format "normal"}
    {status "normal"}
    {return_url ""}
    {return_url_label "[_ ams.lt_Return_to_Where_You_W]"}
}

set provided_return_url $return_url
set provided_return_url_label $return_url_label

set this_url [export_vars -url -base "list" {package_key object_type list_name }]
set code_url [export_vars -url -base "list-code" {package_key object_type list_name return_url return_url_label}]



if { ![ams::list::exists_p -package_key $package_key -object_type $object_type -list_name $list_name] } {
    ad_returnredirect -message "[_ ams.lt_The_list_specified_do]" [export_vars -base "list-add" -url {package_key object_type list_name pretty_name description return_url return_url_label}]
    ad_script_abort
}
set list_id [ams::list::get_list_id -package_key $package_key -object_type $object_type -list_name $list_name]

set create_attribute_url [export_vars -base "attribute-add" -url {object_type list_id return_url return_url_label}]




ams::list::get -list_id $list_id -array "list_info"
set title $list_info(pretty_name)
set context [list [list lists Lists] $title]

list::create \
    -name mapped_attributes \
    -multirow mapped_attributes \
    -key attribute_id \
    -row_pretty_plural "[_ ams.Mapped_Attributes]" \
    -checkbox_name checkbox \
    -selected_format $format \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
    } -actions {
    } -bulk_actions {
	"#ams.Answer_Required#" "list-attributes-required" "#ams.lt_Require_an_answer_fro#"
	"#ams.Answer_Optional#" "list-attributes-optional" "#ams.lt_An_answer_from_the_ch#"
	"#ams.Unmap#" "list-attributes-unmap" "#ams.lt_Unmap_check_attribute#"
	"#ams.Update_Ordering#" "list-order-update" "#ams.lt_Update_ordering_from_#"
    } -bulk_action_export_vars { 
        list_id
    } -elements {
        attribute_name {
            label "[_ ams.Attribute]"
            display_col attribute_name
        }
        pretty_name {
            label "[_ ams.Pretty_Name_1]"
	    display_template {
		<a href="@mapped_attributes.attribute_url@">@mapped_attributes.pretty_name@</a><if $object_type not eq @mapped_attributes.object_type@> (Parent Object Type: <a href="object?object_type=@mapped_attributes.object_type@">@mapped_attributes.object_type@</a>)</if>
	    }
        }
        widget {
            label "[_ ams.Widget_1]"
            display_col widget
            link_url_eval widgets
        }
        section_heading {
            label "[_ ams.Heading]"
            display_col section_heading
        }
	html_options {
	    label "[_ ams.Html_options]"
	    display_col html_options
	}
        action {
            label "[_ ams.Action]"
            display_template {
                <a href="@mapped_attributes.unmap_url@" class="button">[_ ams.Unmap]</a>
                <a href="@mapped_attributes.heading_url@" class="button"><if @mapped_attributes.section_heading@ nil>[_ ams.Add_Heading]</if><else>[_ ams.EditDelete_Heading]</else></a>
		<a href="@mapped_attributes.html_options_url@" class="button"><if @mapped_attributes.html_options@ nil>[_ ams.Add_Html_options]</if><else>[_ ams.EditDelete_Html]</else></a>
            }
        }
        answer {
            label "[_ ams.Required]"
            display_template {
                <if @mapped_attributes.required_p@>
                <a href="@mapped_attributes.optional_url@"><img src="/resources/acs-subsite/checkboxchecked.gif" title="[_ ams.Required]" border="0"></a>
                </if>
                <else>
                <a href="@mapped_attributes.required_url@"><img src="/resources/acs-subsite/checkbox.gif" title="[_ ams.Optional]" border="0"></a>
                </else>
            }
        }
        sort_order {
            label "[_ ams.Ordering]"
            display_template {
                <input name="sort_key.@mapped_attributes.attribute_id@" value="@mapped_attributes.sort_order_key@" size="4">
            }
        }
    } -filters {
    } -groupby {
    } -orderby {
    } -formats {
        normal {
            label "[_ ams.Table]"
            layout table
            row {
                checkbox {}
		attribute_name {}
                pretty_name {}
                sort_order {}
                answer {}
                action {}
		section_heading {}
		html_options {}
            }
        }
    }



set sort_order_count 10

set extend_list [list \
		     sort_order_key \
		     attribute_url \
		     unmap_url \
		     heading_url \
		     required_url \
		     optional_url \
		     html_options_url]

db_multirow -extend $extend_list -unclobber mapped_attributes select_mapped_attributes { } {
    set attribute_url "attribute?[export_vars -url {attribute_id}]"
    set sort_order_key $sort_order_count
    set unmap_url [export_vars -base "list-attributes-unmap" -url {list_id attribute_id return_url return_url_label}]
    set heading_url [export_vars -base "list-attribute-section-heading" -url {list_id attribute_id return_url return_url_label}]
    set required_url [export_vars -base "list-attributes-required" -url {list_id attribute_id return_url return_url_label}]
    set optional_url [export_vars -base "list-attributes-optional" -url {list_id attribute_id return_url return_url_label}]
    set html_options_url [export_vars \
			      -base "list-attribute-html-options" \
			      -url {list_id attribute_id}]

    incr sort_order_count 10
}

list::create \
    -name unmapped_attributes \
    -multirow unmapped_attributes \
    -key attribute_id \
    -row_pretty_plural "[_ ams.Unmapped_Attributes]" \
    -checkbox_name checkbox_unmap \
    -selected_format "normal" \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
     } -bulk_actions {
	 "#ams.Map#" "list-attributes" "#ams.lt_Map_check_attribute#"
     } -bulk_action_export_vars { 
	 list_id
	 return_url
	 return_url_label
	 {command "map"}
     } -actions {
     } -elements {
        attribute_name {
            label "[_ ams.Attribute]"
            display_col attribute_name
        }
        pretty_name {
            label "[_ ams.Pretty_Name_1]"
            display_col pretty_name
            link_url_eval $attribute_url
        }
        widget {
            label "[_ ams.Widget_1]"
            display_col widget
            link_url_eval widgets
        }
        action {
            label "[_ ams.Action]"
            display_template {
                <if @unmapped_attributes.widget@ nil>
		<a href="@unmapped_attributes.attribute_add_url@" class="button">[_ ams.Define_Widget]</a>
		</if>
		<else>
                <a href="@unmapped_attributes.map_url@" class="button">[_ ams.Map]</a>
		</else>
            }
        }
    } -filters {
    } -groupby {
    } -orderby {
    } -formats {
        normal {
            label "[_ ams.Table]"
            layout table
            row {
		checkbox_unmap {}
                pretty_name {}
                widget {}
                action {}
            }
        }
    }
#                checkbox {}



# This query will override the ad_page_contract value entry_id

db_multirow -extend { attribute_url attribute_add_url map_url } -unclobber unmapped_attributes get_unmapped_attributes " " {
    set attribute_add_url [export_vars -base "attribute-add" -url {object_type attribute_name {return_url $this_url}}]
    set attribute_url [export_vars -base "attribute" -url {attribute_id}]
    set map_url [export_vars -base "list-attributes" -url {list_id attribute_id return_url return_url_label {command "map"}}]
}

set return_url $provided_return_url
set return_url_label $provided_return_url_label


ad_return_template
