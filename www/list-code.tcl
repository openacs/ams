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
}

set list_id [ams::list::get_list_id -package_key $package_key -object_type $object_type -list_name $list_name]
ams::list::get -list_id $list_id -array "list_info"
set title $list_info(pretty_name)
set context [list [list lists Lists] $title]

regsub -all {"} $list_info(description) {\"} list_info(description)


db_multirow -extend {message_key true_pretty true_plural} -unclobber attributes select_mapped_attributes {
    select alam.required_p,
    alam.section_heading,
    alam.sort_order as list_sort_order,
    ams.*
    from ams_list_attribute_map alam,
    ams_attributes ams
    where alam.list_id = :list_id
    and alam.attribute_id = ams.attribute_id
    order by alam.sort_order
} {
    regsub -all {"} $section_heading {\"} section_heading
    set message_key "${object_type}_${attribute_name}"
    set pretty_name ams.$message_key
    set pretty_plural ams.${message_key}_plural
    set true_pretty [lang::message::lookup en_US ams.$message_key]
    set true_plural [lang::message::lookup en_US ams.${message_key}_plural]
}

ad_return_template

