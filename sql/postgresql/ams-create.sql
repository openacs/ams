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
--
-- each widget needs to have a ams::widget::${widget} proc associated with it
--
-- the value_method is a reference to a proc that will convert the value_id into a useable string for
-- the tcl procs. If possible it is best to have a value_method, since this substantailly decreases
-- the number of trips that are needed to go the the database. See the example of widgets that come
-- with AMS for more details.

create table ams_widgets (
        widget                  varchar(100)
                                constraint ams_widgets_name_pk primary key,
        pretty_name             varchar(100)
                                constraint ams_widgets_pretty_name_nn not null,
        value_method            varchar(100),
        active_p                boolean
);


------ Attributes
--------------------------------------------------------------------

create table ams_attribute_items (
        attribute_id            integer
                                constraint ams_attribute_items_attribute_id_fk references acs_attributes(attribute_id)
                                constraint ams_attribute_items_attribute_id_nn not null,
        ams_attribute_id        integer
                                constraint ams_attribute_items_ams_attribute_id_fk references acs_objects(object_id)
                                constraint ams_attribute_items_ams_attribute_id_pk primary key,
        widget                  varchar(100)
                                constraint ams_attribute_items_widget_fk references ams_widgets(widget)
                                constraint ams_attribute_items_widget_nn not null,
        dynamic_p               boolean default 'f'
                                constraint ams_attribute_items_dynamic_p_nn not null,
        deprecated_p            boolean default 'f'
                                constraint ams_attribute_items_deprecated_nn not null,
	help_text		varchar(50),
        UNIQUE(attribute_id)
);

create view ams_attributes as
    select acs_attributes.*,
           ams_attribute_items.ams_attribute_id,
           ams_attribute_items.widget,
           ams_attribute_items.dynamic_p,
           ams_attribute_items.deprecated_p
      from acs_attributes left join ams_attribute_items on ( acs_attributes.attribute_id = ams_attribute_items.attribute_id );

select acs_object_type__create_type (
    'ams_attribute',                -- object_type
    '#ams.AMS_Attribute#',                -- pretty_name
    '#ams.AMS_Attributes#',              -- pretty_plural
    'acs_object',                   -- supertype
    'ams_attribute_items',          -- table_name
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
    '#ams.ACS_Attribute_ID#',             -- pretty_name
    '#ams.ACS_Attribute_IDs#',            -- pretty_plural -- default null
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
    'widget',                       -- attribute_name
    'string',                       -- datatype
    '#ams.Widget_1#',                       -- pretty_name
    '#ams.Widgets#',                      -- pretty_plural -- default null
    null,                           -- table_name -- default null
    'widget',                       -- column_name -- default null
    null,                           -- default_value -- default null
    '1',                            -- min_n_values -- default 1
    '1',                            -- max_n_values -- default 1
    null,                           -- sort_order -- default null
    'type_specific',                -- storage -- default 'type_specific'
    null                            -- static_p -- default 'f'
);

-- if uninstalled we can delete acs_attributes dynamically created by
-- the ams ui. Howerver we cannot remove attributes added by other
-- packages because it could break those packages.

select acs_attribute__create_attribute (
    'ams_attribute',                -- object_type
    'dynamic_p',                    -- attribute_name
    'boolean',                      -- datatype
    '#ams.lt_Dynamic_added_by_AMS_#',   -- pretty_name
    '#ams.lt_Dynamic_added_by_AMS_#',   -- pretty_plural -- default null
    null,                           -- table_name -- default null
    'deprecated_p',                 -- column_name -- default null
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
    '#ams.Deprecated#',                   -- pretty_name
    '#ams.Deprecated#',                   -- pretty_plural -- default null
    null,                           -- table_name -- default null
    'deprecated_p',                 -- column_name -- default null
    null,                           -- default_value -- default null
    '1',                            -- min_n_values -- default 1
    '1',                            -- max_n_values -- default 1
    null,                           -- sort_order -- default null
    'type_specific',                -- storage -- default 'type_specific'
    null                            -- static_p -- default 'f'
);



------ Attribute Values
--------------------------------------------------------------------

create table ams_attribute_values (
        object_id               integer
                                constraint ams_attribute_values_object_id_fk references acs_objects(object_id)
                                constraint ams_attribute_values_object_id_nn not null,
        attribute_id            integer
                                constraint ams_attribute_values_attribute_id_fk references acs_attributes(attribute_id)
                                constraint ams_attribute_values_attribute_id_nn not null,
        value_id                integer
                                constraint ams_attribute_values_nn not null
);

create index ams_attribute_values_attribute_idx on ams_attribute_values(attribute_id);
create index ams_attribute_values_attribute_object_idx on ams_attribute_values(object_id,attribute_id);

------ Options
--------------------------------------------------------------------

-- create sequence ams_options_seq; - replace with object key

create table ams_option_types (
        option_id               integer
                                constraint ams_options_option_id_fk references acs_objects(object_id)
                                constraint ams_options_option_id_pk primary key,
        attribute_id            integer 
                                constraint ams_options_attribute_id_nn not null 
                                constraint ams_options_attribute_id_nn references acs_attributes (attribute_id),
        option                  varchar(200)
                                constraint ams_options_option_nn not null,
        sort_order              integer
                                constraint ams_options_sort_order not null,
        deprecated_p            boolean default 'f'
                                constraint ams_options_deprecated_nn not null,
        unique (attribute_id,sort_order)
);


select acs_object_type__create_type (
    'ams_option',                   -- object_type
    '#ams.AMS_Option#',                   -- pretty_name
    '#ams.AMS_Options#',                  -- pretty_plural
    'acs_object',                   -- supertype
    'ams_option_types',             -- table_name
    'option_id',                    -- id_column
    'ams_option',                   -- package_name
    'f',                            -- abstract_p
    null,                           -- type_extension_table
    'ams_option__name'              -- name_method
);

select acs_attribute__create_attribute (
    'ams_option',                   -- object_type
    'attribute_id',                 -- attribute_name
    'integer',                      -- datatype
    '#ams.AMS_Attribute_ID#',             -- pretty_name
    '#ams.AMS_Attribute_IDs#',            -- pretty_plural -- default null
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
    'ams_option',                   -- object_type
    'option',                       -- attribute_name
    'string',                       -- datatype
    '#ams.Option#',                       -- pretty_name
    '#ams.Options#',                      -- pretty_plural -- default null
    null,                           -- table_name -- default null
    'option',                       -- column_name -- default null
    null,                           -- default_value -- default null
    '1',                            -- min_n_values -- default 1
    '1',                            -- max_n_values -- default 1
    null,                           -- sort_order -- default null
    'type_specific',                -- storage -- default 'type_specific'
    null                            -- static_p -- default 'f'
);

select acs_attribute__create_attribute (
    'ams_option',                   -- object_type
    'sort_order',                   -- attribute_name
    'integer',                      -- datatype
    '#ams.Sort_Order#',                   -- pretty_name
    '#ams.Sort_Orders#',                  -- pretty_plural -- default null
    null,                           -- table_name -- default null
    'sort_order',                   -- column_name -- default null
    null,                           -- default_value -- default null
    '1',                            -- min_n_values -- default 1
    '1',                            -- max_n_values -- default 1
    null,                           -- sort_order -- default null
    'type_specific',                -- storage -- default 'type_specific'
    null                            -- static_p -- default 'f'
);

select acs_attribute__create_attribute (
    'ams_option',                -- object_type
    'deprecated_p',                 -- attribute_name
    'boolean',                      -- datatype
    '#ams.Deprecated#',                   -- pretty_name
    '#ams.Deprecated#',                   -- pretty_plural -- default null
    null,                           -- table_name -- default null
    'deprecated_p',                 -- column_name -- default null
    null,                           -- default_value -- default null
    '1',                            -- min_n_values -- default 1
    '1',                            -- max_n_values -- default 1
    null,                           -- sort_order -- default null
    'type_specific',                -- storage -- default 'type_specific'
    null                            -- static_p -- default 'f'
);

create table ams_option_ids (
        value_id                integer
                                constraint ams_options_map_ids_value_id_pk primary key
);

create table ams_options (
        value_id                integer
                                constraint ams_options_value_id_fk references ams_option_ids(value_id)
                                constraint ams_options_value_id_nn not null,
        option_id               integer
                                constraint ams_option_option_id_fk references ams_option_types(option_id)
                                constraint ams_option_map_option_id_nn not null,
        unique (value_id,option_id)
);

------ AMS Texts
--------------------------------------------------------------------

-- use object_id sequence with object_id this allows 
-- for future use of option values being converted into objects.

create table ams_texts (
	value_id 		integer
				constraint ams_texts_text_format_pk primary key,
        text                    text
                                constraint ams_texts_text_format_nn not null,
        text_format             varchar(200) default 'text/plain'
                                constraint ams_texts_text_format_nn not null
);

------ AMS Times
--------------------------------------------------------------------

-- use object_id sequence with object_id this allows 
-- for future use of option values being converted into objects.

create table ams_times (
	value_id 		integer
				constraint ams_times_id_pk primary key,
        time                    timestamptz
                                constraint ams_times_time_nn not null
);

------ AMS Numbers
--------------------------------------------------------------------

-- use object_id sequence with object_id this allows 
-- for future use of option values being converted into objects.

create table ams_numbers (
	value_id 		integer
				constraint ams_numbers_id_pk primary key,
        number                  numeric
                                constraint ams_numbers_number_nn not null
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
    '#ams.AMS_List#',                     -- pretty_name
    '#ams.AMS_Lists#',                   -- pretty_plural
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
    '#ams.Package_Key_1#',                  -- pretty_name
    '#ams.Package_Keys#',                 -- pretty_plural -- default null
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
    '#ams.Object_Type_1#',                  -- pretty_name
    '#ams.Object_Types#',                 -- pretty_plural -- default null
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
    '#ams.List_Name_1#',                    -- pretty_name
    '#ams.List_Names#',                   -- pretty_plural -- default null
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
    '#ams.Pretty_Name_1#',                  -- pretty_name
    '#ams.Pretty_Names#',                 -- pretty_plural -- default null
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
    '#ams.Description#',                  -- pretty_name
    '#ams.Descriptions#',                 -- pretty_plural -- default null
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
    '#ams.lt_Description_Mime_Type#',        -- pretty_name
    '#ams.lt_Descriptions_Mime_Typ#',      -- pretty_plural -- default null
    null,                           -- table_name -- default null
    'description_mime_type',        -- column_name -- default null
    null,                           -- default_value -- default null
    '1',                            -- min_n_values -- default 1
    '1',                            -- max_n_values -- default 1
    null,                           -- sort_order -- default null
    'type_specific',                -- storage -- default 'type_specific'
    null                            -- static_p -- default 'f'
);

-- create sequence ams_list_attribute_sort_order_seq;

create table ams_list_attribute_map (
        list_id                 integer
                                constraint ams_list_attribute_map_list_id_fk references ams_lists(list_id)
                                constraint ams_list_attribute_map_list_id_nn not null,
        attribute_id            integer
                                constraint ams_list_attribute_map_attribute_id_fk references acs_attributes(attribute_id)
                                constraint ams_list_attribute_map_attribute_id_nn not null,
        sort_order              integer
                                constraint ams_list_attribute_map_sort_order_nn not null,
        required_p              boolean
                                constraint ams_list_attribute_map_required_p_nn not null,
        section_heading         varchar(200),
	html_options            varchar(1000),
        UNIQUE(list_id,attribute_id),
        UNIQUE(list_id,sort_order)
);

\i ams-package-create.sql
-- \i populate.sql
\i telecom-number-missing-plsql.sql
