--
-- packages/ams/sql/postgresql/ams-create.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-09-07
-- @cvs-id $Id$
--
--


------ Widgets
--------------------------------------------------------------------

create table ams_storage_types (
        storage_type            varchar(20)
                                constraint ams_storage_type_nn not null
                                constraint ams_storage_type_pk primary key
);

create table ams_widgets (
        widget_name             varchar(100)
                                constraint ams_widgets_name_pk primary key,
        pretty_name             varchar(100)
                                constraint ams_widgets_pretty_name_nn not null,
        pretty_plural           varchar(100)
                                constraint ams_widgets_pretty_plural_nn not null,
        storage_type            varchar(20)
                                constraint ams_widgets_storage_type_nn not null
                                constraint contact_widgets_storage_type_fk references ams_storage_types(storage_type),
        acs_datatype            varchar(50)
                                constraint ams_widgets_acs_datatype_nn not null
                                constraint ams_widgets_acs_datatype_fk references acs_datatypes(datatype),
        widget	                varchar(20) 
                                constraint ams_widgets_widget_nn not null,
        datatype                varchar(20) 
                                constraint ams_widgets_datatype_nn not null,
        parameters              varchar(1000)
);



------ Attributes
--------------------------------------------------------------------

create table ams_attributes (
        ams_attribute_id        integer
                                constraint ams_attributes_ams_attribute_id_fk references acs_objects(object_id)
                                constraint ams_attributes_ams_attribute_id_pk primary key,
        attribute_id            integer
                                constraint ams_attributes_attribute_id_fk references acs_attributes(attribute_id)
                                constraint ams_attributes_attribute_id_nn not null,
        widget_name             varchar(100)
                                constraint ams_attributes_widget_name_fk references ams_widgets(widget_name)
                                constraint ams_attributes_widget_name_nn not null,
        deprecated_p            boolean default 'f'
                                constraint ams_attributes_deprecated_nn not null
);

select acs_object_type__create_type (
    'ams_attribute',                -- object_type
    'AMS Attribute',                -- pretty_name
    'AMS Attributes ',              -- pretty_plural
    'acs_object',                   -- supertype
    'ams_attributes',               -- table_name
    'ams_attribute_id',             -- id_column
    'ams_attribute',                -- package_name
    'f',                            -- abstract_p
    null,                           -- type_extension_table
    'ams_attribute__name'           -- name_method
);

select acs_attribute__create_attribute (
    'ams_attribute',                -- object_type
    'attribute_id',                 -- attribute_name
    'integer',                      -- datatype
    'ACS Attribute ID',             -- pretty_name
    'ACS Attribute IDs',            -- pretty_plural -- default null
    null,                           -- table_name -- default null
    'attribute_id',                 -- column_name -- default null
    null,                           -- default_value -- default null
    '1',                            -- min_n_values -- default 1
    '1',                            -- max_n_values -- default 1
    null,                           -- sort_order -- default null
    'type_specific',                -- storage -- default 'type_specific'
    null                            -- static_p -- default 'f'
);

select acs_attribute__create_attribute (
    'ams_attribute',                -- object_type
    'widget_name',                  -- attribute_name
    'string',                       -- datatype
    'Widget Name',                  -- pretty_name
    'Widget Name',                  -- pretty_plural -- default null
    null,                           -- table_name -- default null
    'widget_name',                  -- column_name -- default null
    null,                           -- default_value -- default null
    '1',                            -- min_n_values -- default 1
    '1',                            -- max_n_values -- default 1
    null,                           -- sort_order -- default null
    'type_specific',                -- storage -- default 'type_specific'
    null                            -- static_p -- default 'f'
);

select acs_attribute__create_attribute (
    'ams_attribute',                -- object_type
    'deprecated_p',                 -- attribute_name
    'boolean',                      -- datatype
    'Deprecated',                   -- pretty_name
    'Deprecated',                   -- pretty_plural -- default null
    null,                           -- table_name -- default null
    'deprecated_p',                 -- column_name -- default null
    null,                           -- default_value -- default null
    '1',                            -- min_n_values -- default 1
    '1',                            -- max_n_values -- default 1
    null,                           -- sort_order -- default null
    'type_specific',                -- storage -- default 'type_specific'
    null                            -- static_p -- default 'f'
);


------ Objects
--------------------------------------------------------------------

-- In order to allow for an acs_object to become a cr_item
-- we need to do a one to one cr_item to acs_object map. This
-- allows for no content repository controlled acs_objects
-- to get revisions, via their associated ams_object

create table ams_objects (
        ams_object_id           integer
                                constraint ams_objects_ams_object_id_fk references cr_items(item_id) on delete cascade
                                constraint ams_objects_ams_object_id_pk primary key,
        object_id               integer
                                constraint ams_object_revisions_object_id_fk references acs_objects(object_id)
                                constraint ams_object_revisions_object_id_nn not null,
        unique(object_id)
);

create table ams_object_revisions (
        ams_object_revision_id  integer
                                constraint ams_object_revisions_revision_id_fk references cr_revisions(revision_id) on delete cascade
                                constraint ams_object_revisions_revision_id_pk primary key
);

-- create the CR content type

select content_type__create_type (
  'ams_object_revision',       -- content_type
  'content_revision',          -- supertype    
  'AMS Object',                -- pretty_name 
  'AMS Objects',               -- pretty_plural
  'ams_object_revisions',      -- table_name 
  'ams_object_revision_id',    -- id_column 
  'ams_object_revision__name'  -- name_method
);



------ Options
--------------------------------------------------------------------


create sequence ams_options_seq;
create table ams_options (
        option_id               integer
                                constraint ams_options_option_id_nn not null
                                constraint ams_options_option_id_nn primary key,
        ams_attribute_id        integer 
                                constraint ams_options_ams_attribute_id_nn not null 
                                constraint ams_options_ams_attribute_id_nn references ams_attributes (ams_attribute_id),
        option                  varchar(200)
                                constraint ams_options_option_nn not null,
        sort_order              integer
                                constraint ams_options_sort_order not null,
        unique (ams_attribute_id,sort_order)
);

create sequence ams_option_map_id_seq;
create table ams_option_map_ids (
        option_map_id           integer
                                constraint ams_option_map_ids_option_map_id_pk primary key
);

create table ams_option_map (
        option_map_id           integer
                                constraint ams_option_map_option_map_id_nn not null
                                constraint ams_option_map_option_map_id_fk references ams_option_map_ids(option_map_id),
        option_id               integer
                                constraint ams_option_map_option_id_fk references ams_options(option_id)
                                constraint ams_option_map_option_id_nn not null
);



------ Attribute Values
--------------------------------------------------------------------



create table ams_attribute_values (
        revision_id             integer
                                constraint ams_attribute_values_revision_id_fk references cr_revisions(revision_id)
                                constraint ams_attribute_values_revision_id_nn not null,
        superseed_revision_id   integer
                                constraint ams_attribute_values_superseed_revision_id_fk references cr_revisions(revision_id),
        ams_attribute_id            integer
                                constraint ams_attribute_values_ams_attribute_id_fk references ams_attributes(ams_attribute_id)
                                constraint ams_attribute_values_ams_attribute_id_nn not null,
        option_map_id           integer
                                constraint ams_attribute_values_option_id_fk references ams_option_map_ids(option_map_id),
        address_id              integer
                                constraint ams_attribute_values_address_id_fk references postal_addresses(address_id),
        number_id               integer
                                constraint ams_attribute_values_number_id_fk references telecom_numbers(number_id),
        time                    timestamptz,
        value                   text,
        value_mime_type         character varying(50) default 'text/plain'
                                constraint ams_attribute_values_mime_type_fk references cr_mime_types(mime_type)
);





------ Lists
--------------------------------------------------------------------

-- We now create groupings of ams attributes, we call them lists
-- since these groupings will be used to create lists of elements
-- for ad_form as well as lists of certain attributes to be used
-- by other applications.

create table ams_lists (
        list_id                 integer
                                constraint ams_lists_list_id_fk references acs_objects(object_id)
                                constraint ams_lists_list_id_pk primary key,
        package_key             varchar(100)
                                constraint ams_lists_package_key_fk references apm_package_types(package_key)
                                constraint ams_lists_package_key_nn not null,
        object_type             varchar(1000)
                                constraint ams_lists_object_type_fk references acs_object_types(object_type)
                                constraint ams_lists_object_type_nn not null,
        list_name               varchar(100)
                                constraint ams_lists_list_name_nn not null,
        pretty_name             varchar(200)
                                constraint ams_lists_pretty_name_nn not null,
        description             varchar(200),
        description_mime_type   varchar(200)
                                constraint ams_lists_description_mime_type_fk references cr_mime_types(mime_type),
        UNIQUE(package_key,object_type,list_name)
);

select acs_object_type__create_type (
    'ams_list',                     -- object_type
    'AMS List',                     -- pretty_name
    'AMS Lists ',                   -- pretty_plural
    'acs_object',                   -- supertype
    'ams_lists',                    -- table_name
    'list_id',                      -- id_column
    'ams_list',                     -- package_name
    'f',                            -- abstract_p
    null,                           -- type_extension_table
    'ams_list__name'                -- name_method
);

select acs_attribute__create_attribute (
    'ams_list',                     -- object_type
    'package_key',                  -- attribute_name
    'string',                       -- datatype
    'Package Key',                  -- pretty_name
    'Package Keys',                 -- pretty_plural -- default null
    null,                           -- table_name -- default null
    'object_type',                  -- column_name -- default null
    null,                           -- default_value -- default null
    '1',                            -- min_n_values -- default 1
    '1',                            -- max_n_values -- default 1
    null,                           -- sort_order -- default null
    'type_specific',                -- storage -- default 'type_specific'
    null                            -- static_p -- default 'f'
);

select acs_attribute__create_attribute (
    'ams_list',                     -- object_type
    'object_type',                  -- attribute_name
    'string',                       -- datatype
    'Object Type',                  -- pretty_name
    'Object Types',                 -- pretty_plural -- default null
    null,                           -- table_name -- default null
    'object_type',                  -- column_name -- default null
    null,                           -- default_value -- default null
    '1',                            -- min_n_values -- default 1
    '1',                            -- max_n_values -- default 1
    null,                           -- sort_order -- default null
    'type_specific',                -- storage -- default 'type_specific'
    null                            -- static_p -- default 'f'
);

select acs_attribute__create_attribute (
    'ams_list',                     -- object_type
    'list_name',                    -- attribute_name
    'string',                       -- datatype
    'List Name',                    -- pretty_name
    'List Names',                   -- pretty_plural -- default null
    null,                           -- table_name -- default null
    'list_name',                    -- column_name -- default null
    null,                           -- default_value -- default null
    '1',                            -- min_n_values -- default 1
    '1',                            -- max_n_values -- default 1
    null,                           -- sort_order -- default null
    'type_specific',                -- storage -- default 'type_specific'
    null                            -- static_p -- default 'f'
);

select acs_attribute__create_attribute (
    'ams_list',                     -- object_type
    'pretty_name',                  -- attribute_name
    'string',                       -- datatype
    'Pretty Name',                  -- pretty_name
    'Pretty Names',                 -- pretty_plural -- default null
    null,                           -- table_name -- default null
    'pretty_name',                  -- column_name -- default null
    null,                           -- default_value -- default null
    '1',                            -- min_n_values -- default 1
    '1',                            -- max_n_values -- default 1
    null,                           -- sort_order -- default null
    'type_specific',                -- storage -- default 'type_specific'
    null                            -- static_p -- default 'f'
);

select acs_attribute__create_attribute (
    'ams_list',                     -- object_type
    'description',                  -- attribute_name
    'text',                         -- datatype
    'Description',                  -- pretty_name
    'Descriptions',                 -- pretty_plural -- default null
    null,                           -- table_name -- default null
    'description',                  -- column_name -- default null
    null,                           -- default_value -- default null
    '1',                            -- min_n_values -- default 1
    '1',                            -- max_n_values -- default 1
    null,                           -- sort_order -- default null
    'type_specific',                -- storage -- default 'type_specific'
    null                            -- static_p -- default 'f'
);

select acs_attribute__create_attribute (
    'ams_list',                     -- object_type
    'description_mime_type',        -- attribute_name
    'text',                         -- datatype
    'Description Mime Type',        -- pretty_name
    'Descriptions Mime Types',      -- pretty_plural -- default null
    null,                           -- table_name -- default null
    'description_mime_type',        -- column_name -- default null
    null,                           -- default_value -- default null
    '1',                            -- min_n_values -- default 1
    '1',                            -- max_n_values -- default 1
    null,                           -- sort_order -- default null
    'type_specific',                -- storage -- default 'type_specific'
    null                            -- static_p -- default 'f'
);

create sequence ams_list_attribute_sort_order_seq;

create table ams_list_attribute_map (
        list_id                integer
                                constraint ams_list_attribute_map_list_id_fk references ams_lists(list_id)
                                constraint ams_list_attribute_map_list_id_nn not null,
        ams_attribute_id            integer
                                constraint ams_list_attribute_map_ams_attribute_id_fk references ams_attributes(ams_attribute_id)
                                constraint ams_list_attribute_map_ams_attribute_id_nn not null,
        sort_order              integer
                                constraint ams_list_attribute_map_sort_order_nn not null,
        required_p              boolean
                                constraint ams_list_attribute_map_required_p_nn not null,
        section_heading         varchar(200),
        UNIQUE(list_id,ams_attribute_id),
        UNIQUE(list_id,sort_order)
);

\i ams-package-create.sql
\i populate.sql
\i telecom-number-missing-plsql.sql
