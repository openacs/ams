--
-- packages/ams/sql/postgresql/ams-drop.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-09-07
-- @cvs-id $Id$
--
--


select content_folder__delete (folder_id, 't') 
  from cr_folders
 where label = 'AMS Objects'
   and description = 'AMS Object Repository';

delete from cr_folder_type_map where content_type = 'ams_object_revision';
delete from acs_attribute_descriptions where description_key = 'ams_attribute_description';

select drop_package('ams_option');
select drop_package('ams_attribute');
select drop_package('ams_attribute_value');
select drop_package('ams_object_revision');

drop function ams_object__new (integer,integer,timestamptz,integer,varchar);
drop function ams_object_id (integer);
-- select drop_package('ams_object_id');
select drop_package('ams_list');


drop sequence ams_options_id_seq;
drop sequence ams_option_map_id_seq;
drop sequence ams_list_attribute_sort_order_seq;

drop table ams_list_attribute_map;
drop table ams_lists;
drop view ams_object_revisionsx;
drop view ams_object_revisionsi;
drop table ams_object_revisions cascade;
drop table ams_objects cascade;
drop table ams_attribute_values cascade;
drop table ams_option_map cascade;
drop table ams_option_map_ids cascade;
drop table ams_options cascade;
drop table ams_attributes cascade;
drop table ams_widgets cascade;
drop table ams_storage_types cascade;
update cr_items set live_revision = null, latest_revision = null where content_type = 'ams_object_revision';
delete from cr_revisions where item_id in ( select item_id from cr_items where content_type = 'ams_object_revision' );
delete from cr_items where content_type = 'ams_object_revision';
delete from acs_objects where object_type in ('ams_list','ams_object_revision','ams_attribute');
select acs_object_type__drop_type('ams_list','f');
select acs_object_type__drop_type('ams_object_revision','f');
select acs_object_type__drop_type('ams_attribute','f');
