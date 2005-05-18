<?xml version="1.0"?>
<queryset>


<fullquery name="ams::list::get.select_list_info">
  <querytext>
        select *
          from ams_lists
         where list_id = :list_id
  </querytext>
</fullquery>


<fullquery name="ams::list::ams_attribute_ids_not_cached.ams_attribute_ids">
  <querytext>
        select attribute_id
          from ams_list_attribute_map
         where list_id = :list_id
  </querytext>
</fullquery>


<fullquery name="ams::list::exists_p.list_exists_p">
  <querytext>
        select '1' 
          from ams_lists
         where package_key = :package_key
           and object_type = :object_type
           and list_name = :list_name
  </querytext>
</fullquery>

<fullquery name="ams::list::get_list_id_not_cached.get_list_id">
  <querytext>
        select list_id
          from ams_lists
         where package_key = :package_key
           and object_type = :object_type
           and list_name = :list_name
  </querytext>
</fullquery>


<fullquery name="ams::list::attribute::map.ams_list_attribute_map">
  <querytext>
        select ams_list__attribute_map (
                :list_id,
                :attribute_id,
                :sort_order,
                :required_p,
                :section_heading
        )
  </querytext>
</fullquery>

<fullquery name="ams::list::attribute::map.get_highest_sort_order">
  <querytext>
        select sort_order
          from ams_list_attribute_map
         where list_id = :list_id
         order by sort_order desc
         limit 1
  </querytext>
</fullquery>

<fullquery name="ams::list::attribute::unmap.ams_list_attribute_unmap">
  <querytext>
        delete from ams_list_attribute_map
         where list_id = :list_id
           and attribute_id = :attribute_id
  </querytext>
</fullquery>

<fullquery name="ams::list::attribute::required.ams_list_attribute_required">
  <querytext>
        update ams_list_attribute_map
           set required_p = 't'
         where list_id = :list_id
           and attribute_id = :attribute_id
  </querytext>
</fullquery>

<fullquery name="ams::list::attribute::optional.ams_list_attribute_optional">
  <querytext>
        update ams_list_attribute_map
           set required_p = 'f'
         where list_id = :list_id
           and attribute_id = :attribute_id
  </querytext>
</fullquery>




</queryset>
