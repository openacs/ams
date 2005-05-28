--
-- packages/ams/sql/postgresql/ams-drop.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-09-07
-- @cvs-id $Id$
--
--




create or replace function inline_1 ()
returns varchar as '
declare
        rec                RECORD;
begin

        FOR rec IN 
                select value_id
                  from ams_attribute_values
        LOOP
                delete from ams_attribute_values where address_id = rec.value_id;
                PERFORM postal_address__del (rec.value_id); 
        END LOOP;

        return ''All Postal Addresses associated with AMS have been deleted'';
end;' language 'plpgsql';

select inline_1() as Notice;
drop function inline_1();

create or replace function inline_2 ()
returns varchar as '
declare
        rec                RECORD;
begin

        FOR rec IN 
                select value_id
                  from ams_attribute_values
                 where value_id is not null
        LOOP
                delete from ams_attribute_values where number_id = rec.value_id;
                PERFORM telecom_number__del (rec.value_id); 
        END LOOP;

        
        return ''All Telecom Numbers Addresses associated with AMS have been deleted'';
end;' language 'plpgsql';

select inline_2() as Notice;
drop function inline_2();


delete from ams_attribute_values;
select ams_attribute__delete(attribute_id)
  from ams_attributes
 where ams_attribute_id is not null;

select drop_package('ams_option');
select drop_package('ams_attribute');
select drop_package('ams_list');
select drop_package('ams_value');
select drop_package('ams_widget');

-- select acs_object__delete(address_id) from ams_attribute_values where address_id is not null;
-- select acs_object__delete(number_id) from ams_attribute_values where number_id is not null;

drop table ams_list_attribute_map;
drop table ams_lists;
drop table ams_options;
drop table ams_option_ids;
drop table ams_numbers;
drop table ams_times;
drop table ams_texts;
drop table ams_option_types;
drop table ams_attribute_values;
drop view ams_attributes;
drop table ams_attribute_items;
drop table ams_widgets;

delete from acs_objects where object_type in ('ams_attribute','ams_list','ams_option');
select acs_object_type__drop_type('ams_attribute','f');
select acs_object_type__drop_type('ams_list','f');
select acs_object_type__drop_type('ams_option','f');
