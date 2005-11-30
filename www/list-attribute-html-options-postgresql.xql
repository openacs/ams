<?xml version="1.0"?>
<queryset>

<fullquery name="get_html_options">
    <querytext>
	select 
		alam.html_options
      	from 
		ams_list_attribute_map alam,
                ams_attributes aa,
                ams_lists al
        where 
		alam.attribute_id = aa.attribute_id
                and alam.list_id = al.list_id
                and alam.list_id = :list_id
                and alam.attribute_id = :attribute_id
    </querytext>
</fullquery>

<fullquery name="update_html_options">
    <querytext>
	update ams_list_attribute_map
	set html_options = :html_options
        where list_id = :list_id
        and attribute_id = :attribute_id
    </querytext>
</fullquery>

</queryset>