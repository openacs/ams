<?xml version="1.0"?>
<queryset>

<fullquery name="select_mapped_attributes">
    <querytext>
	select 
		alam.required_p,
               	alam.section_heading,
               	alam.html_options,
               	ams.attribute_id,
               	ams.widget,
               	ams.deprecated_p,
               	ams.attribute_name,
               	ams.pretty_name,
               	ams.pretty_plural,
               	ams.object_type
	from 
		ams_list_attribute_map alam,
               	ams_attributes ams
        where 
		alam.list_id = :list_id
           	and alam.attribute_id = ams.attribute_id
        order by 
		alam.sort_order
    </querytext>
</fullquery>

<fullquery name="get_unmapped_attributes">
    <querytext>
	select 
		attribute_id,
               	widget,
               	deprecated_p,
               	attribute_name,
               	pretty_name,
               	pretty_plural,
               	object_type
      	from 
		ams_attributes
        where 
		attribute_id not in 
				( 
				select 
					alam.attribute_id 
				from 
					ams_list_attribute_map alam 
				where 
					alam.list_id = :list_id 
				)
           	and object_type in ([ams::object_parents -sql -object_type $object_type])
    </querytext>
</fullquery>

</queryset>