ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$

} {
    {attribute_id:notnull}
    orderby:optional
}

#db_1row get_attribute_info {}
ams::attribute::get -attribute_id $attribute_id -array "attribute_info"
acs_object_type::get -object_type $attribute_info(object_type) -array "object_info"


set pretty_name $attribute_info(pretty_name)
set pretty_plural $attribute_info(pretty_plural)
set title $pretty_name
set context [list [list objects Objects] [list "object?object_type=$attribute_info(object_type)" $object_info(pretty_name)] $title]

list::create \
    -name options \
    -multirow options \
    -key option_id \
    -row_pretty_plural "[_ ams.Options]" \
    -checkbox_name checkbox \
    -selected_format "normal" \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
    } -actions {
    } -bulk_action_export_vars { 
        attribute_id
    } -bulk_actions {
	"#acs-kernel.common_Update#" "attribute-options-update" "#ams.Update_Options#"        
    } -elements {
        edit {
            label {}
        }
        option {
            label "[_ ams.Option]"
            display_template {
                <if @options.option@ not nil>
                  @options.option@
                </if>
                <else>
                  <input name="option.@options.option_id@" value="" size="35">
                </else>
            }
        }
        sort_order {
            label "[_ ams.Sort_Order]"
            display_template {
                <input name="sort_key.@options.option_id@" value="@options.sort_order@" size="4">
            }
        }
        actions {
            label ""
            display_template {
                <if @options.in_use_p@></if><else><a href="@options.delete_url@"><img src="/shared/images/Delete16.gif" height="16" width="16" alt="Delete" border="0"></a></else>
            }
        }
    } -filters {
    } -groupby {
    } -orderby {
        default_value default_sort,asc
        default_sort {
            label default_sort
            multirow_cols {sort_key option}
        }
    } -formats {
        normal {
            label "Table"
            layout table
            row {
                option {}
                sort_order {}
                actions {}
            }
        }
    }


set sort_count 10
set sort_key_count 10000
db_multirow -extend { sort_order sort_key delete_url } options select_options {
    select option_id, option,
           CASE WHEN ( select '1' from ams_options where ams_options.option_id = ams_option_types.option_id limit 1 ) IS NULL THEN 0 ELSE 1 END as in_use_p
      from ams_option_types
     where attribute_id = :attribute_id
     order by sort_order
} {
    set sort_order $sort_count
    set sort_key $sort_key_count
    incr sort_count 10
    incr sort_key_count 1
    set delete_url [export_vars -base "attribute-option-delete" -url {attribute_id option_id}]
}

if { [template::multirow size options] > 0 } {
    set sort_order $sort_count
    set sort_key $sort_key_count
    template::multirow append options {new1} {} 1 $sort_count $sort_key
    template::multirow append options {new2} {} 1 [incr sort_count 10] [incr sort_key 1]
    template::multirow append options {new3} {} 1 [incr sort_count 10] [incr sort_key 1]
}
ad_return_template
