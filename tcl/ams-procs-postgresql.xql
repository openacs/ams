<?xml version="1.0"?>
<queryset>

<fullquery name="ams_object_id_not_cached.select_ams_object_id">
  <querytext>
        select ams_object_id(:object_id)
  </querytext>
</fullquery>

<fullquery name="ams_object_id_not_cached.create_and_select_ams_object_id">
  <querytext>
        select ams_object__new(
                :object_id,
                :package_id,
                now(),
                :creation_user,
                :creation_ip
        );
  </querytext>
</fullquery>

<fullquery name="ams::option::new.ams_option_new">
  <querytext>
        select ams_option__new (:ams_attribute_id,:option,:sort_order)
  </querytext>
</fullquery>

<fullquery name="ams::option::delete.ams_option_delete">
  <querytext>
        select ams_option__delete (:option_id)
  </querytext>
</fullquery>


<fullquery name="ams::option::map.ams_option_map">
  <querytext>
        select ams_option__map (:option_map_id,:option_id)
  </querytext>
</fullquery>

<fullquery name="ams::attribute::widget_not_cached.select_attribute">
  <querytext>
        select ac.attribute_name, 
               ac.pretty_name,
               ac.object_type,
               aw.widget,
               aw.datatype,
               aw.parameters,
               aw.storage_type
          from ams_attributes aa,
               acs_attributes ac,
               ams_widgets aw
         where aa.ams_attribute_id = :ams_attribute_id
           and aa.attribute_id = ac.attribute_id
           and aa.widget_name = aw.widget_name
  </querytext>
</fullquery>

<fullquery name="ams::attribute::widget_not_cached.select_options">
  <querytext>
        select option, option_id
          from ams_options
         where ams_attribute_id = :ams_attribute_id
         order by sort_order 
  </querytext>
</fullquery>

<fullquery name="ams::attribute::exists_p.attribute_exists_p">
  <querytext>
        select '1' from acs_attributes where object_type = :object_type and attribute_name = :attribute_name
  </querytext>
</fullquery>

<fullquery name="ams::attribute::get_ams_attribute_id.get_ams_attribute_id">
  <querytext>
        select ams.ams_attribute_id
          from ams_attributes ams, acs_attributes acs
         where acs.object_type = :object_type
           and acs.attribute_name = :attribute_name
           and acs.attribute_id = ams.attribute_id
  </querytext>
</fullquery>

<fullquery name="ams::attribute::name_not_cached.ams_attribute_name">
  <querytext>
        select ams_attribute__name (:ams_attribute_id)
  </querytext>
</fullquery>

<fullquery name="ams::attribute::storage_type_not_cached.ams_attribute_storage_type">
  <querytext>
        select aw.storage_type
          from ams_widgets aw, ams_attributes aa
         where aa.ams_attribute_id = :ams_attribute_id
           and aw.widget_name = aa.widget_name
  </querytext>
</fullquery>

<fullquery name="ams::attribute::delete.ams_attribute_delete">
  <querytext>
        select ams_attribute__delete (:ams_attribute_id)
  </querytext>
</fullquery>

<fullquery name="ams::object::attribute::values_batch_process.get_attr_values">
  <querytext>
        select aav.*, 
               ao.object_id,
               ams_attribute__postal_address_string(address_id) as address_string,
               ams_attribute__telecom_number_string(number_id) as telecom_number_string
          from ams_attribute_values aav, cr_revisions cr, ams_objects ao
         where ao.object_id in ($sql_object_id_list)
           and ao.ams_object_id = cr.item_id 
           and cr.revision_id = aav.revision_id
           and aav.superseed_revision_id is null
         order by ao.object_id, aav.ams_attribute_id
  </querytext>
</fullquery>

<fullquery name="ams::attribute::value::save.ams_attribute_value_new">
  <querytext>
        select ams_attribute_value__new (
                :revision_id,
                :ams_attribute_id,
                :option_map_id,
                :address_id,
                :number_id,
                :time,
                :value,
                :value_mime_type
        )
  </querytext>
</fullquery>


<fullquery name="ams::attribute::value::save.ams_attribute_value_save">
  <querytext>
        select ams_attribute_value__save (
                :revision_id,
                :ams_attribute_id,
                :option_map_id,
                :address_id,
                :number_id,
                :time,
                :value,
                :value_mime_type
        )
  </querytext>
</fullquery>

<fullquery name="ams::attribute::value::new.create_telecom_number_object">
  <querytext>
        select acs_object__new (
                 null,
                 'telecom_number',
                 ( select creation_date from acs_objects where object_id = :revision_id ),
                 ( select creation_user from acs_objects where object_id = :revision_id ),
                 ( select creation_ip from acs_objects where object_id = :revision_id ),
                 :revision_id
        )
  </querytext>
</fullquery>

<fullquery name="ams::attribute::value::new.create_telecom_number">
  <querytext>
        insert into telecom_numbers (
               number_id,
               itu_id,
               national_number,
               area_city_code,
               subscriber_number,
               extension,
               sms_enabled_p,
               best_contact_time,
               location,
               phone_type_id
        ) values ( 
               :number_id,
               :itu_id,
               :national_number,
               :area_city_code,
               :subscriber_number,
               :extension,
               :sms_enabled_p,
               :best_contact_time,
               :location,
               :phone_type_id
        )
  </querytext>
</fullquery>

<fullquery name="ams::attribute::value::new.create_postal_address_object">
  <querytext>
        select acs_object__new (
               null,
               'postal_address',
               ( select creation_date from acs_objects where object_id = :revision_id ),
               ( select creation_user from acs_objects where object_id = :revision_id ),
               ( select creation_ip from acs_objects where object_id = :revision_id ),
               :revision_id
        )
  </querytext>
</fullquery>

<fullquery name="ams::attribute::value::new.create_postal_address">
  <querytext>
        insert into postal_addresses (
               address_id,
               delivery_address,
               municipality,
               region,
               postal_code,
               country_code,
               additional_text,
               postal_type
        ) values ( 
               :address_id,
               :delivery_address,
               :municipality,
               :region,
               :postal_code,
               :country_code,
               :additional_text,
               :postal_type
        )
  </querytext>
</fullquery>

<fullquery name="ams::attribute::value::new.insert_attribute_value">
  <querytext>
        insert into ams_attribute_values
        (revision_id,ams_attribute_id,option_map_id,address_id,number_id,time,value,value_mime_type)
        values
        (:revision_id,:ams_attribute_id,:option_map_id,:address_id,:number_id,:time,:value,:value_mime_type)
  </querytext>
</fullquery>

<fullquery name="ams::attribute::value::superseed.superseed_attribute_value">
  <querytext>
        update ams_attribute_values
           set superseed_revision_id = :revision_id
         where ams_attribute_id = :ams_attribute_id
           and superseed_revision_id is null
           and revision_id in ( select revision_id
                                  from cr_revisions
                                 where item_id = :ams_object_id
                                   and revision_id <> :revision_id )
  </querytext>
</fullquery>

<fullquery name="ams::list::ams_attribute_ids_not_cached">
  <querytext>
        select ams_attribute_id
          from ams_list_attribute_map
         where list_id = :list_id
  </querytext>
</fullquery>


<fullquery name="ams::list::exists_p.list_exists_p">
  <querytext>
        select '1' 
          from ams_lists
         where short_name = :short_name
           and package_key = :package_key
           and object_type = :object_type
  </querytext>
</fullquery>

<fullquery name="ams::list::get_list_id.get_list_id">
  <querytext>
        select list_id
          from ams_lists
         where short_name = :short_name
           and package_key = :package_key
           and object_type = :object_type
  </querytext>
</fullquery>


<fullquery name="ams::list::attribute_map.ams_list_attribute_map">
  <querytext>
        select ams_list__attribute_map (
                :list_id,
                :ams_attribute_id,
                :sort_order,
                :required_p,
                :section_heading
        )
  </querytext>
</fullquery>































<fullquery name="contacts::postal_address::get.select_address_info">
  <querytext>
        select * from postal_addresses where address_id = :address_id
  </querytext>
</fullquery>


<fullquery name="contacts::telecom_number::new.telecom_number_new">
  <querytext>
        select telecom_number__new (
                             :area_city_code,
                             :best_contact_time,
                             :extension,
                             :itu_id,
                             :location,
                             :national_number,
                             null,
                             null,
                             null,
                             :sms_enabled_p,
                             :subscriber_number,
                             :creation_user,
                             :creation_ip,
                             null
                             )
  </querytext>
</fullquery>


<fullquery name="contacts::telecom_number::get.select_telecom_number_info">
  <querytext>
        select * from telecom_numbers where number_id = :number_id
  </querytext>
</fullquery>


<fullquery name="contacts::get::ad_form_elements.select_attributes">
  <querytext>
	select *
        from contact_attributes ca,
             contact_widgets cw,
             contact_attribute_object_map caom,
             contact_attribute_names can
        where caom.object_id = :object_id
              and ca.ams_attribute_id = can.ams_attribute_id
              and can.locale = :locale
              and caom.ams_attribute_id = ca.ams_attribute_id
              and ca.widget_id = cw.widget_id
              and not ca.depreciated_p
              and acs_permission__permission_p(ca.ams_attribute_id,:user_id,'write')
        order by caom.sort_order
  </querytext>
</fullquery>


<fullquery name="contacts::get::values::multirow.select_attribute_values">
<querytext>

       select ca.ams_attribute_id,
                 ca.attribute, 
                 cav.option_map_id,
                 cav.address_id,
                 cav.number_id,
                 to_char(cav.time,'YYYY MM DD') as time,
                 cav.value,
                 cav.value_format,
                 cw.storage_column
            from contact_attributes ca,
                 contact_widgets cw,
                 contact_attribute_object_map caom left join 
                     ( select *
                         from contact_attribute_values 
                        where party_id = :party_id
                          and not deleted_p ) cav
                 on (caom.ams_attribute_id = cav.ams_attribute_id)
           where caom.object_id = '$object_id'
             and caom.ams_attribute_id = ca.ams_attribute_id
             and ca.widget_id = cw.widget_id
             and not ca.depreciated_p
             and (
                      cav.option_map_id   is not null 
                   or cav.address_id      is not null
                   or cav.number_id       is not null
                   or cav.value           is not null
                   or cav.time            is not null
                   or ca.attribute in ($custom_field_sql_list)
                 )
             and acs_permission__permission_p(ca.ams_attribute_id,'$user_id','$permission')
           order by caom.sort_order
</querytext>
</fullquery>


<fullquery name="contacts::get::values::multirow.organization_name_from_party_id">
  <querytext>
        select name
          from organizations
         where organization_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::get::values::multirow.legal_name_from_party_id">
  <querytext>
        select legal_name
          from organizations
         where organization_id = :party_id 
  </querytext>
</fullquery>


<fullquery name="contacts::get::values::multirow.reg_number_from_party_id">
  <querytext>
        select reg_number
          from organizations
         where organization_id = :party_id 
  </querytext>
</fullquery>


<fullquery name="contacts::get::values::multirow.first_names_from_party_id">
  <querytext>
        select first_names
          from persons
         where person_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::get::values::multirow.organization_types_from_party_and_ams_attribute_id">
  <querytext>
        select cao.option_id, cao.option
        from contact_attribute_options cao,
               organization_types ot,
               organization_type_map otm
        where cao.option = ot.type
           and cao.ams_attribute_id  = :ams_attribute_id
           and otm.organization_type_id = ot.organization_type_id
           and otm.organization_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contact::get::values::multirow.first_names_from_party_id">
  <querytext>
        select first_names
          from persons
         where person_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::get::values::multirow.last_name_from_party_id">
  <querytext>
        select last_name
          from persons
         where person_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::get::values::multirow.email_from_party_id">
  <querytext>
        select email
          from parties
         where party_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::get::values::multirow.url_from_party_id">
  <querytext>
        select url
          from parties
         where party_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::get::values::multirow.select_options_from_map">
  <querytext>
        select cao.option, cao.option_id
          from contact_attribute_options cao,
               contact_attribute_option_map caom
         where caom.option_id = cao.option_id
           and caom.option_map_id = :option_map_id
  </querytext>
</fullquery>

<fullquery name="contacts::save::ad_form::values.select_attributes">
  <querytext>
        select *
            from contact_attributes ca,
                  contact_widgets cw,
                  contact_attribute_object_map caom,
                  contact_attribute_names can
            where caom.object_id = :object_id
              and ca.ams_attribute_id = can.ams_attribute_id
              and can.locale = :locale
              and caom.ams_attribute_id = ca.ams_attribute_id
              and ca.widget_id = cw.widget_id
              and not ca.depreciated_p
              and acs_permission__permission_p(ca.ams_attribute_id,:user_id,'write')
            order by caom.sort_order
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.select_old_address_id">
  <querytext>
        select cav.address_id as old_address_id
        from contact_attribute_values cav,
             postal_addresses pa
        where cav.party_id = :party_id
           and cav.ams_attribute_id = :ams_attribute_id
           and not cav.deleted_p
           and cav.address_id = pa.address_id
           and pa.delivery_address = :delivery_address
           and pa.municipality = :municipality
           and pa.region = :region
           and pa.postal_code = :postal_code
           and pa.country_code = :country_code
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.select_old_number_id">
  <querytext>
        select cav.number_id as old_number_id
        from contact_attribute_values cav,
             telecom_numbers tn
        where cav.party_id = :party_id
           and cav.ams_attribute_id = :ams_attribute_id
           and not cav.deleted_p
           and cav.number_id = tn.number_id
           and tn.subscriber_number = :attribute_value_temp
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.get_option_map_id">
  <querytext>
        select option_map_id 
	from contact_attribute_values
	where party_id = :party_id
	   and ams_attribute_id = :ams_attribute_id and not deleted_p
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.get_old_options">
  <querytext>
        select option_id
	from contact_attribute_option_map 
	where option_map_id  = :option_map_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.get_new_option_map_id">
  <querytext>
        select nextval('contact_attribute_option_map_id_seq') as option_map_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.insert_options_map">
  <querytext>
        insert into contact_attribute_option_map
           (option_map_id,party_id,option_id)
        values
           (:option_map_id,:party_id,:option_id)
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.update_parties_email">
  <querytext>
        update parties set email = :attribute_value_temp where party_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.update_parties_url">
  <querytext>
        update parties set url = :attribute_value_temp where party_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.update_organizations_name">
  <querytext>
        update organizations set name = :attribute_value_temp where organization_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.update_organizations_legal_name">
  <querytext>
        update organizations set legal_name = :attribute_value_temp where organization_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.update_organizations_reg_number">
  <querytext>
        update organizations set reg_number = :attribute_value_temp where organization_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.delete_org_type_maps">
  <querytext>
        delete from organization_type_map where organization_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.get_organization_type_id">
  <querytext>
        select organization_type_id
        from contact_attribute_options cao,
             organization_types ot
        where cao.option = ot.type
           and cao.option_id  = :option_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.insert_mapping">
  <querytext>
        insert into organization_type_map
           (organization_id, organization_type_id)
        values
           (:party_id, :organization_type_id)
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.update_persons_first_names">
  <querytext>
        update persons set first_names = :attribute_value_temp where person_id = :party_id
  </querytext>
</fullquery>


<fullquery name="contacts::save::ad_form::values.update_persons_last_name">
  <querytext>
        update persons set last_name = :attribute_value_temp where person_id = :party_id
  </querytext>
</fullquery>


</queryset>
