<?xml version="1.0"?>
<queryset>

<fullquery name="attribute::new.create_attribute">
  <querytext>
        select acs_attribute__create_attribute (
		:object_type,
		:attribute_name,
		:datatype,
		:pretty_name,
		:pretty_plural,
		:table_name,
		:column_name,
		:default_value,
		:min_n_values,
		:max_n_values,
		:sort_order,
		:storage,
		:static_p
	)
  </querytext>
</fullquery>

<fullquery name="attribute::id.get_attribute_id">
  <querytext>
        select attribute_id
          from acs_attributes
         where object_type = :object_type
           and attribute_name = :attribute_name
  </querytext>
</fullquery>

<fullquery name="ams::attribute::value_save.attribute_value_save">
  <querytext>
    select ams_attribute_value__save (
      :object_id,
      :attribute_id,
      :value_id
    )
  </querytext>
</fullquery>

<fullquery name="ams::ad_form::elements.select_elements">
  <querytext>
        select alam.attribute_id,
               alam.required_p,
               alam.section_heading,
               aa.attribute_name,
               aa.pretty_name,
               aa.widget
          from ams_list_attribute_map alam,
               ams_attributes aa
         where alam.attribute_id = aa.attribute_id
           and alam.list_id = :list_id
         order by alam.sort_order
  </querytext>
</fullquery>

<fullquery name="ams::ad_form::save.select_elements">
  <querytext>
        select alam.attribute_id,
               alam.required_p,
               alam.section_heading,
               aa.attribute_name,
               aa.pretty_name,
               aa.widget
          from ams_list_attribute_map alam,
               ams_attributes aa
         where alam.attribute_id = aa.attribute_id
           and alam.list_id = :list_id
         order by alam.sort_order
  </querytext>
</fullquery>

<fullquery name="ams::ad_form::values.select_values">
  <querytext>
     select aav.*, aa.attribute_name, aa.widget, aa.pretty_name,
            ams_attribute_value__value(aav.attribute_id,aav.value_id) as value
       from ams_attribute_values aav,
            ams_attributes aa
      where aav.object_id = :object_id
        and aav.attribute_id = aa.attribute_id
        and aa.attribute_id in ( select attribute_id from ams_list_attribute_map where list_id = :list_id )
  </querytext>
</fullquery>

</queryset>
