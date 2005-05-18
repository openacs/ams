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


db_multirow -unclobber attributes select_mapped_attributes {
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
         regsub -all {"} $pretty_name {\"} pretty_name
         regsub -all {"} $pretty_plural {\"} pretty_plural
}




ad_return_template





