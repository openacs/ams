--
-- packages/ams/sql/postgresql/ams-package-create.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-09-07
-- @cvs-id $Id$
--
--


------ Attributes
--------------------------------------------------------------------



select define_function_args('ams_attribute__new','ams_attribute_id,object_type,attribute_name,pretty_name,pretty_plural,default_value,description,widget_name,deprecated_p;f,creation_date,creation_user,creation_ip,context_id');

create or replace function ams_attribute__new (integer,varchar,varchar,varchar,varchar,varchar,text,varchar,boolean,timestamptz,integer,varchar,integer)
returns integer as '
declare
        p_ams_attribute_id   alias for $1; -- the AMS Attribute ID
        p_object_type        alias for $2;
        p_attribute_name     alias for $3;
        p_pretty_name        alias for $4; 
        p_pretty_plural      alias for $5; 
        p_default_value      alias for $6; 
        p_description        alias for $7; 
        p_widget_name        alias for $8; 
        p_deprecated_p       alias for $9; 
        p_creation_date      alias for $10;
        p_creation_user      alias for $11;
        p_creation_ip        alias for $12;
        p_context_id         alias for $13;
        v_attribute_id       integer;
        v_acs_datatype       varchar;
        v_ams_attribute_id   integer;
begin

        v_acs_datatype := acs_datatype from ams_widgets where widget_name = p_widget_name;

        v_attribute_id := acs_attribute__create_attribute (
                p_object_type,
                p_attribute_name,
                v_acs_datatype,
                p_pretty_name,
                p_pretty_plural,
                null,               -- p_table_name
                null,               -- p_column_name
                p_default_value,
                ''0'',              -- p_min_n_values
                ''1'',              -- p_max_n_values
                null,               -- p_sort_order
                ''type_specific'',  -- p_storage
                ''f''               -- p_static_p
        );

        if p_description is not null then
                PERFORM acs_attribute__add_description (
                                p_object_type,
                                p_attribute_name,
                                ''ams_attribute_description'',
                                p_description
                );
        end if;

        v_ams_attribute_id := acs_object__new (
                p_ams_attribute_id,
                ''ams_attribute'',
                p_creation_date,
                p_creation_user,
                P_creation_ip,
                p_context_id
        );

        insert into ams_attributes
                (ams_attribute_id,attribute_id,widget_name,deprecated_p)
        values
                (v_ams_attribute_id,v_attribute_id,p_widget_name,p_deprecated_p);

        return v_ams_attribute_id;
end;' language 'plpgsql';



create or replace function ams_attribute__name (integer)
returns varchar as '
declare
        p_ams_attribute_id  alias for $1;
        v_name          varchar;
begin
        v_name := acs_attributes.attribute_name 
             from acs_attributes, ams_attributes
            where ams_attributes.ams_attribute_id = p_ams_attribute_id
              and ams_attributes.attribute_id = acs_attributes.attribute_id;

        return v_name;
end;' language 'plpgsql';

create or replace function ams_attribute__pretty_name (integer)
returns varchar as '
declare
        p_ams_attribute_id  alias for $1;
        v_name          varchar;
begin
        v_name := acs_attributes.pretty_name 
             from acs_attributes, ams_attributes
            where ams_attributes.ams_attribute_id = p_ams_attribute_id
              and ams_attributes.attribute_id = acs_attributes.attribute_id;

        return v_name;
end;' language 'plpgsql';

create or replace function ams_attribute__delete (integer)
returns integer as '
declare
        p_ams_attribute_id      alias for $1;
        v_object_type       varchar;
        v_attribute_name    varchar;
begin
        select acs_attributes.attribute_name, acs_attributes.object_type
          into v_object_type, v_attribute_name
          from acs_attributes, ams_attributes
         where ams_attributes.attribute_id = acs_attributes.attribute_id;

        delete from ams_attribute_values where ams_attribute_id = p_ams_attribute_id;

        PERFORM acs_object__delete (
                        p_ams_attribute_id
                );

        PERFORM acs_attribute__drop_description (
                        v_object_type,
                        v_attribute_name,
                        ''ams_attribute_description''
                );

        PERFORM acs_attribute__drop_attribute (
                        v_object_type,
                        v_attribute_name
                );

        return 0;
end;' language 'plpgsql';






------ Objects
--------------------------------------------------------------------


create or replace function ams_object_revision__root_folder (integer)
returns integer as '
declare
        p_package_id            alias for $1;
        v_folder_id             integer;
        v_count                 integer;
        v_folder_name           varchar;
begin
        v_count := count(*) from cr_folders where package_id = p_package_id;

        if v_count = 0 then

                v_folder_name := package_key || ''_'' || p_package_id from apm_packages
                           where package_id = p_package_id;

                -- create a new root folder
                v_folder_id := content_folder__new (
                        v_folder_name,                  -- name
                        ''AMS Objects'',                -- label
                        ''AMS Object Repository'',      -- description
                        null,                           -- parent_id
                        p_package_id,                   -- parent_id
                        null,                           -- folder_id
                        null,                           -- creation_date
                        null,                           -- creation_user
                        null                            -- creation_ip
                );

                -- register folder content types
                PERFORM content_folder__register_content_type (
                        v_folder_id,                    -- folder_id
                        ''ams_object_revision'',        -- content_type
                        ''f''                           -- include_subtypes
                );

                -- there is no facility in the API for adding in the package_id,
                -- so we have to do it ourselves

                update cr_folders 
                   set package_id = p_package_id 
                 where folder_id = v_folder_id;

        else
                v_folder_id := folder_id from cr_folders where package_id = p_package_id;
        end if;

        return v_folder_id;

end; ' language 'plpgsql';



-- select define_function_args('ams_object_id','object_id,package_id,creation_date;now(),creation_user,creation_ip');
-- get the ams_object_id, and none exists create a new content item

create or replace function ams_object__new (integer,integer,timestamptz,integer,varchar)
returns integer as '
declare
        p_object_id          alias for $1;
        p_package_id         alias for $2;
        p_creation_date      alias for $3;
        p_creation_user      alias for $4;
        p_creation_ip        alias for $5;
        v_ams_object_id      integer;
        v_count              integer;
begin
        v_count := count(*) from ams_objects where object_id = p_object_id;

        if v_count = 0 then

                -- create a new item
                v_ams_object_id := content_item__new (
                        p_object_id::varchar,                   -- name
                        ams_object_revision__root_folder(p_package_id),  -- parent_id
                        null,                                   -- item_id
                        null,                                   -- locale
                        p_creation_date,                        -- creation_date
                        p_creation_user,                        -- creation_user
                        p_object_id,                            -- context_id
                        p_creation_ip,                          -- creation_ip
                        ''content_item'',                       -- item_subtype
                        ''ams_object_revision'',                -- content_type
                        null,                                   -- title
                        null,                                   -- description
                        null,                                   -- mime_type
                        null,                                   -- nls_language
                        null                                    -- data
                );

                insert into ams_objects
                (ams_object_id,object_id)
                values
                (v_ams_object_id,p_object_id);

        else
                v_ams_object_id := ams_object_id(p_object_id);
        end if;

        return v_ams_object_id;
end;' language 'plpgsql';



create or replace function ams_object_id (integer)
returns integer as '
declare
        p_object_id          alias for $1;
        v_ams_object_id      integer;
begin
        return ams_object_id from ams_objects where object_id = p_object_id;
end;' language 'plpgsql';



select define_function_args('ams_object_revision__new','object_id,package_id,creation_date;now(),creation_user,creation_ip');

create or replace function ams_object_revision__new (integer,integer,timestamptz,integer,varchar)
returns integer as '
declare
        p_object_id          alias for $1;
        p_package_id         alias for $2;
        p_creation_date      alias for $3;
        p_creation_user      alias for $4;
        p_creation_ip        alias for $5;
        v_ams_object_id           integer;
        v_ams_object_revision_id  integer;
begin

        -- get the ams_object_id and create the content item if necessary
        v_ams_object_id := ams_object__new (
                p_object_id,
                p_package_id,
                p_creation_date,
                p_creation_user,
                p_creation_ip
        );                

        v_ams_object_revision_id := content_revision__new (
                null,                   -- title
                null,                   -- description
                now(),                  -- publish_date
                null,                   -- mime_type
                null,                   -- nls_language
                null,                   -- data
                v_ams_object_id,        -- item_id
                null,                   -- revision_id
                p_creation_date,        -- creation_date
                p_creation_user,        -- creation_user
                p_creation_ip           -- creation_ip
        );

        PERFORM content_item__set_live_revision (v_ams_object_revision_id);

        insert into ams_object_revisions
        (ams_object_revision_id)
        values
        (v_ams_object_revision_id);

        return v_ams_object_revision_id;
end;' language 'plpgsql';



------ Options                                        
--------------------------------------------------------------------

create or replace function ams_option__new (integer,varchar,integer)
returns integer as '
declare
        p_ams_attribute_id      alias for $1;
        p_option                alias for $2;
        p_sort_order            alias for $3;
        v_option_id             integer;
begin

        v_option_id := nextval(''ams_options_seq'');

        insert into ams_options
        (option_id,ams_attribute_id,option,sort_order)
        values
        (v_option_id,p_ams_attribute_id,p_option,p_sort_order);

        return v_option_id;
end;' language 'plpgsql';


create or replace function ams_option__delete(integer)
returns integer as '
declare
        p_option_id             alias for $1;
begin
        delete from ams_options where object_id = p_option_id;

        return 0;
end;' language 'plpgsql';

create or replace function ams_option__map (integer,integer)
returns integer as '
declare
        p_option_map_id         alias for $1;
        p_option_id             alias for $2;
        v_option_map_id         integer;
begin

        if count(*) from ams_option_map where option_map_id = p_option_map_id = ''0'' then

                v_option_map_id := nextval(''ams_option_map_id_seq'');
                insert into ams_option_map_ids(option_map_id) value (v_option_map_id);
       
        else 
                v_option_map_id := p_option_map_id;

        end if;

        insert into ams_option_map
        (option_map_id,option_id)
        values
        (v_option_map_id,p_option_id);

        return v_option_map_id;
end;' language 'plpgsql';





------ Attribute Values
--------------------------------------------------------------------

-- Unlike the ams_attribute_value__save proc below this one,
-- ams_attribute_value__new will save null entries (i.e. when
-- no value was given for an attribute). this will chew up
-- database space (with non-value rows). but it can be called
-- upon by content repository managed objects to store attribute
-- values with that objects revision_id (as opposed to the ams
-- managed revision_id). This is useful when permissions are not
-- set to hide certain attributes from users. If the attributes
-- for an object are restrict based on permissions the ams_object
-- container is preferred since it is made to deal with the
-- retrieval and display of this more complex form of content
-- revision. Note, this proc does not mark previous revisions as
-- superseeded, so if another objects revisions are used you must
-- make sure that the attribute has not already been entered for
-- this particular revision.



create or replace function ams_attribute_value__new (integer,integer,integer,integer,integer,timestamptz,text,varchar)
returns integer as '
declare
        p_revision_id                alias for $1;
        p_ams_attribute_id           alias for $2;
        p_option_map_id              alias for $3;
        p_address_id                 alias for $4;
        p_number_id                  alias for $5;
        p_time                       alias for $6;
        p_value                      alias for $7;
        p_value_mime_type            alias for $8;
begin
        insert into ams_attribute_values
        (revision_id,ams_attribute_id,option_map_id,address_id,number_id,time,value,value_mime_type)
        values
        (p_revision_id,p_ams_attribute_id,p_option_map_id,p_address_id,p_number_id,p_time,p_value,p_value_mime_type);

        return 0;
end;' language 'plpgsql';



create or replace function ams_attribute_value__superseed (integer,integer,integer)
returns integer as '
declare
        p_revision_id                alias for $1;
        p_ams_attribute_id           alias for $2;
        p_ams_object_id              alias for $3;
begin

        update ams_attribute_values
           set superseed_ams_attribute_id = p_revision_id
         where ams_attribute_id = p_ams_attribute_id
           and superseed_revision_id is null
           and revision_id in ( select revision_id
                                  from cr_revisions
                                 where item_id = p_ams_object_id );


        return 0;
end;' language 'plpgsql';



create or replace function ams_attribute_value__save (integer,integer,integer,integer,integer,timestamptz,text,varchar)
returns integer as '
declare
        p_revision_id                alias for $1;
        p_ams_attribute_id           alias for $2;
        p_option_map_id              alias for $3;
        p_address_id                 alias for $4;
        p_number_id                  alias for $5;
        p_time                       alias for $6;
        p_value                      alias for $7;
        p_value_mime_type            alias for $8;
        v_ams_object_id              integer;
        v_count                      integer;
        v_option_map_id              integer;
        v_address_id                 integer;
        v_number_id                  integer;
        v_time                       timestamptz;
        v_value                      text;
        v_value_mime_type            varchar;
        v_insert_new_p               boolean;
        v_duplicate_p                boolean;
begin

        v_ams_object_id := item_id from cr_revisions where revision_id = p_revision_id;

        v_count := count(*) from ams_attribute_values 
                           where superseed_revision_id is null
                             and revision_id in ( select revision_id
                                                    from cr_revisions
                                                   where item_id = v_ams_object_id );

        if v_count > 0 then
                select option_map_id,
                       address_id,
                       number_id,
                       time, 
                       value,
                       value_mime_type
                  into v_option_map_id,
                       v_address_id,
                       v_number_id,
                       v_time,
                       v_value,
                       v_value_mime_type
                  from ams_attribute_values
                 where ams_attribute_id = p_ams_attribute_id
                   and revision_id in ( select revision_id
                                          from cr_items
                                         where item_id = v_ams_object_id )
                   and superseed_revision_id is not null;

                if v_option_map_id != p_option_map_id
                        or v_address_id != p_address_id
                        or v_number_id != p_number_id
                        or v_time != p_time
                        or v_value != p_value
                then
                        PERFORM ams_attribute_value__superseed (
                                        p_revision_id,
                                        p_ams_attribute_id,
                                        v_ams_object_id
                        );
                        
                        v_duplicate_p := ''f'';
                else
                        v_duplicate_p := ''t'';

                end if;
        else
                v_duplicate_p := ''f'';
        end if;

        
        if not v_duplicate_p then
                -- we know that this is not duplicate

                if p_option_map_id is not null
                   or p_address_id is not null
                   or p_number_id is not null
                   or p_time is not null
                   or p_value is not null
                then
                        -- there is a not null value to this attribute
                        PERFORM ams_attribute_value__new (
                                        p_revision_id,
                                        p_ams_attribute_id,
                                        p_option_map_id,
                                        p_address_id,
                                        p_number_id,
                                        p_time,
                                        p_value,
                                        p_value_mime_type
                        );
                end if;

        end if;


        return 0;
end;' language 'plpgsql';



------ Groups
--------------------------------------------------------------------



select define_function_args('ams_list__new','list_id,package_key,object_type,list_name,pretty_name,description,description_mime_type,creation_date,creation_user,creation_ip,context_id');

create or replace function ams_list__new (integer,varchar,varchar,varchar,varchar,varchar,varchar,timestamptz,integer,varchar,integer)
returns integer as '
declare
        p_list_id               alias for $1;
        p_package_key           alias for $2;
        p_object_type           alias for $3;
        p_list_name             alias for $4;
        p_pretty_name           alias for $5;
        p_description           alias for $6;
        p_description_mime_type alias for $7;
        p_creation_date         alias for $8;
        p_creation_user         alias for $9;
        p_creation_ip           alias for $10;
        p_context_id            alias for $11;
        v_list_id               integer;
begin

        v_list_id := acs_object__new (
                p_list_id,
                ''ams_list'',
                p_creation_date,
                p_creation_user,
                P_creation_ip,
                p_context_id
        );

        insert into ams_lists
        (list_id,package_key,object_type,list_name,pretty_name,description,description_mime_type)
        values
        (v_list_id,p_package_key,p_object_type,p_list_name,p_pretty_name,p_description,p_description_mime_type);

        return v_list_id;
end;' language 'plpgsql';

create or replace function ams_list__attribute_map (integer,integer,integer,boolean,varchar)
returns integer as '
declare
        p_list_id            alias for $1;
        p_ams_attribute_id   alias for $2;
        p_sort_order         alias for $3;
        p_required_p         alias for $4;
        p_section_heading    alias for $5;
        v_sort_order         integer;
begin

        if p_sort_order is null then
           v_sort_order := nextval(''ams_list_attribute_sort_order_seq'');
        else
           v_sort_order := p_sort_order;
        end if;

        delete from ams_list_attribute_map
         where ams_attribute_id = p_ams_attribute_id
           and list_id = p_list_id;

        insert into ams_list_attribute_map
                (list_id,ams_attribute_id,sort_order,required_p,section_heading)
        values
                (p_list_id,p_ams_attribute_id,v_sort_order,p_required_p,p_section_heading);

        return ''1'';
end;' language 'plpgsql';














------ Postal Address
--------------------------------------------------------------------

-- postal_type needs to be entered here at the end... this is a hack
-- CASE WHEN postal_type is not null THEN postal_type ELSE '''' END || ''}''
-- it needs to be consistently recast as an integer

create or replace function ams_attribute__postal_address_string (integer)
returns varchar as '
declare
        p_address_id    alias for $1;
        v_name          text;
begin

        if p_address_id is not null then
                v_name :=  ''{'' || 
                           CASE WHEN delivery_address is not null THEN delivery_address ELSE '''' END || ''} {'' || 
                           CASE WHEN municipality is not null THEN municipality ELSE '''' END || ''} {'' || 
                           CASE WHEN region is not null THEN region ELSE '''' END  || ''} {'' || 
                           CASE WHEN postal_code is not null THEN postal_code ELSE '''' END  || ''} {'' ||
                           CASE WHEN country_code is not null THEN country_code::varchar ELSE '''' END  || ''} {'' ||
                           CASE WHEN additional_text is not null THEN additional_text ELSE '''' END || ''} {}''
                      from postal_addresses
                     where address_id = p_address_id;
        else
                v_name := NULL;
        end if;

        return v_name;
end;' language 'plpgsql';



------ Telecom Number
--------------------------------------------------------------------


create or replace function ams_attribute__telecom_number_string (integer)
returns varchar as '
declare
        p_number_id     alias for $1;
        v_name          text;
begin

        if p_number_id is not null then
                v_name :=  ''{'' || 
                  CASE WHEN itu_id is not null THEN itu_id ELSE '''' END || ''} {'' || 
                  CASE WHEN national_number is not null THEN national_number ELSE '''' END || ''} {'' || 
                  CASE WHEN area_city_code is not null THEN area_city_code ELSE '''' END  || ''} {'' || 
                  CASE WHEN subscriber_number is not null THEN subscriber_number ELSE '''' END  || ''} {'' ||
                  CASE WHEN extension is not null THEN extension ELSE '''' END  || ''} {'' ||
                  CASE WHEN sms_enabled_p is not null THEN CASE WHEN sms_enabled_p THEN ''1'' ELSE ''0'' END ELSE '''' END || ''} {'' ||
                  CASE WHEN best_contact_time is not null THEN best_contact_time ELSE '''' END || ''} {'' ||
                  CASE WHEN location is not null THEN location ELSE '''' END || ''} {'' ||
                  CASE WHEN phone_type_id is not null THEN phone_type_id ELSE '''' END || ''}''
             from telecom_numbers
             where number_id = p_number_id;
        else
                v_name := NULL;
        end if;

        return v_name;
end;' language 'plpgsql';

