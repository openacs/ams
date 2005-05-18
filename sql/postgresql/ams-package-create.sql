--
-- packages/ams/sql/postgresql/ams-package-create.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-09-07
-- @cvs-id $Id$
--
--
-- object_id          | integer                  | not null
-- object_type        | character varying(100)   | not null
-- context_id         | integer                  |
-- security_inherit_p | boolean                  | not null default true
-- creation_user      | integer                  |
-- creation_date      | timestamp with time zone | not null default ('now'::text)::timestamp(6) with time zone
-- creation_ip        | character varying(50)    |
-- last_modified      | timestamp with time zone | not null default ('now'::text)::timestamp(6) with time zone
-- modifying_user     | integer                  |
-- modifying_ip       | character varying(50)    |
-- tree_sortkey       | bit varying              | not null
-- max_child_sortkey  | bit varying              |

------ Widgets 
--------------------------------------------------------------------

create or replace function ams_widget__save (varchar,varchar,varchar,boolean)
returns integer as '
declare
        p_widget             alias for $1;
        p_pretty_name        alias for $2;
        p_value_method       alias for $3;
        p_active_p           alias for $4;
        v_exists_p           boolean;
begin
	v_exists_p := ''1'' from ams_widgets where widget = p_widget;

        if v_exists_p then

         	update ams_widgets
                   set pretty_name = p_pretty_name,
                       value_method = p_value_method,
                       active_p = p_active_p
                 where widget = p_widget;        

        else
                insert into ams_widgets 
                (widget,pretty_name,value_method,active_p)
                values
                (p_widget,p_pretty_name,p_value_method,p_active_p);
	end if;

        return ''1'';
end;' language 'plpgsql';



------ Attributes
--------------------------------------------------------------------

select define_function_args('ams_attribute__new','attribute_id,ams_attribute_id,widget,dynamic_p;f,deprecated_p;f,creation_date;now(),creation_user,creation_ip,context_id');

create or replace function ams_attribute__new (integer,integer,varchar,boolean,boolean,timestamptz,integer,varchar,integer)
returns integer as '
declare
        p_attribute_id       alias for $1;
        p_ams_attribute_id   alias for $2; -- the Permissable AMS Attribute ID
        p_widget             alias for $3;
        p_dynamic_p          alias for $4;
        p_deprecated_p       alias for $5;
        p_creation_date      alias for $6;
        p_creation_user      alias for $7;
        p_creation_ip        alias for $8;
        p_context_id         alias for $9;
        v_ams_attribute_id   integer;
begin

        v_ams_attribute_id := acs_object__new (
                p_ams_attribute_id,
                ''ams_attribute'',
                p_creation_date,
                p_creation_user,
                P_creation_ip,
                p_context_id
        );

        insert into ams_attribute_items
                (attribute_id,ams_attribute_id,widget,dynamic_p,deprecated_p)
        values
                (p_attribute_id,v_ams_attribute_id,p_widget,p_dynamic_p,p_deprecated_p);

        return v_ams_attribute_id;
end;' language 'plpgsql';



create or replace function ams_attribute__name (integer)
returns varchar as '
declare
        p_ams_attribute_id  alias for $1;
        v_name              varchar;
begin
        v_name := attribute_name 
             from ams_attributes
            where ams_attribute_id = p_ams_attribute_id;

        return v_name;
end;' language 'plpgsql';

create or replace function ams_attribute__delete (integer)
returns integer as '
declare
        p_ams_attribute_id      alias for $1;
        v_attribute_id          integer;
        v_object_type           varchar;
        v_attribute_name        varchar;
        v_dynamic_p             boolean;
begin
        select attribute_id, attribute_name, object_type, dynamic_p
          info v_attribute_id, v_object_type, v_attribute_name, v_dynamic_p
          from ams_attributes
         where ams_attribute_id = :ams_attribute_id;

        delete from ams_attribute_values where attribute_id = v_attribute_id;

        PERFORM acs_object__delete (
                        p_ams_attribute_id
                );

        if v_dynamic_p then

        PERFORM acs_attribute__drop_attribute (
                        v_object_type,
                        v_attribute_name
                );

        end if;

        return 0;
end;' language 'plpgsql';










------ Attribute Values
--------------------------------------------------------------------

create or replace function ams_attribute_value__save (integer,integer,integer)
returns integer as '
declare
        p_object_id                  alias for $1;
        p_attribute_id               alias for $2;
        p_value_id                   alias for $3;
        v_count                      integer;
begin

        delete from ams_attribute_values
         where object_id = p_object_id
           and attribute_id = p_attribute_id; 

	if p_value_id is not null then
                insert into ams_attribute_values
                (object_id,attribute_id,value_id)
                values
                (p_object_id,p_attribute_id,p_value_id);
	end if;

        return 0;
end;' language 'plpgsql';


create or replace function ams_attribute_value__value (integer,integer)
returns text as '
declare
  p_attribute_id           alias for $1;
  p_value_id               alias for $2;  
  v_value_method           varchar; 
  v_value                  text;
  val                      record;
begin

  v_value_method := value_method
       from ams_widgets
      where widget = ( select widget
                         from ams_attributes
                        where attribute_id = p_attribute_id );

  if v_value_method != '''' and v_value_method is NOT null then
    for val in execute ''select '' || v_value_method || ''('' || p_value_id || '')::text as value'' loop
        v_value := val.value;
        exit;
    end loop;
  end if;

  return v_value;
  
end;' language 'plpgsql' stable strict;

------ Options                                        
--------------------------------------------------------------------

select define_function_args('ams_option__new','option_id,attribute_id,option,sort_order,depreacted_p;f,creation_date,creation_user,creation_ip,context_id');

create or replace function ams_option__new (integer,integer,varchar,integer,boolean,timestamptz,integer,varchar,integer)
returns integer as '
declare
        p_option_id             alias for $1;
        p_attribute_id          alias for $2;
        p_option                alias for $3;
        p_sort_order            alias for $4;
        p_deprecated_p          alias for $5;
        p_creation_date         alias for $6;
        p_creation_user         alias for $7;
        p_creation_ip           alias for $8;
        p_context_id            alias for $9;
        v_option_id             integer;
        v_sort_order            integer;
begin

        v_option_id := acs_object__new (
                p_option_id,
                ''ams_option'',
                p_creation_date,
                p_creation_user,
                P_creation_ip,
                p_context_id
        );

        if p_sort_order is null then
                v_sort_order := v_option_id;
        else
                v_sort_order := p_sort_order;
        end if;

        insert into ams_option_types
        (option_id,attribute_id,option,sort_order,deprecated_p)
        values
        (v_option_id,p_attribute_id,p_option,v_sort_order,p_deprecated_p);

        return v_option_id;
end;' language 'plpgsql';


create or replace function ams_option__delete(integer)
returns integer as '
declare
        p_option_id             alias for $1;
begin
        delete from ams_options where object_id = p_option_id;
        PERFORM acs_object__delete (
                        p_option_id
                );

        return 0;
end;' language 'plpgsql';

create or replace function ams_option__name (integer)
returns varchar as '
declare
        p_option_id         alias for $1;
        v_name              varchar;
begin
        v_name := option
             from ams_option_types
            where option_id = p_option_id;

        return v_name;
end;' language 'plpgsql';

create or replace function ams_option__map (integer,integer)
returns integer as '
declare
        p_value_id              alias for $1;
        p_option_id             alias for $2;
        v_value_id              integer;
        v_count                 integer;
begin
        v_count := count(*) from ams_options where value_id = p_value_id;

        if v_count = ''0'' or p_value_id is null then
                v_value_id := nextval from acs_object_id_seq;
                insert into ams_option_ids(value_id) values (v_value_id);
        else 
                v_value_id := p_value_id;
        end if;

        insert into ams_options
        (value_id,option_id)
        values
        (v_value_id,p_option_id);

        return v_value_id;
end;' language 'plpgsql';

create or replace function ams_value__options (integer)
returns text as '
declare
        p_value_id    alias for $1;
        v_name             text;
        rec                RECORD;
begin

        v_name := NULL;
        if p_value_id is not null then
                FOR rec IN 
                        select option_id 
                          from ams_options
                         where value_id = p_value_id
                         order by option_id
                LOOP
                        IF v_name is null THEN
                                v_name := rec.option_id;
                        ELSE
                                v_name := v_name || '' '' || rec.option_id;
                        END IF;
                END LOOP;
        end if;

        return v_name;
end;' language 'plpgsql';

create or replace function ams_value__asses (text)
returns integer as '
declare
        p_ams_value__options    alias for $1;
        v_value_id              integer
begin

        v_value_id := value_id
          from ams_options_ids
         where ams_value__options(value_id) = p_ams_value__options;

        return v_value_id;
end;' language 'plpgsql';

------ AMS Texts
--------------------------------------------------------------------

create or replace function ams_value__text_save (text,varchar)
returns integer as '
declare
        p_text          alias for $1;
        p_text_format   alias for $2;
        v_value_id      integer;
begin

	v_value_id := value_id
                        from ams_texts
                       where text = p_text
                         and text_format = p_text_format;

        if v_value_id is null then
                v_value_id := nextval from acs_object_id_seq;
                insert into ams_texts
                (value_id,text,text_format) 
                values
                (v_value_id,p_text,p_text_format);
        end if;

        return v_value_id;
end;' language 'plpgsql';

create or replace function ams_value__text(integer)
returns varchar as '
declare
        p_value_id    alias for $1;
        v_value       text;
begin
        v_value := ''{'' || text_format::text || ''} '' || text from ams_texts where value_id = p_value_id;
        return v_value;
end;' language 'plpgsql';

------ AMS Times
--------------------------------------------------------------------

create or replace function ams_value__time_save (timestamptz)
returns integer as '
declare
        p_time          alias for $1;
        v_value_id      integer;
begin

	v_value_id := value_id
                        from ams_times
                       where time = p_time;

        if v_value_id is null then
                v_value_id := nextval from acs_object_id_seq;
                insert into ams_times
                (value_id,time) 
                values
                (v_value_id,p_time);
        end if;

        return v_value_id;
end;' language 'plpgsql';

create or replace function ams_value__time(integer)
returns text as '
declare
        p_value_id    alias for $1;
        v_value       text;
begin
        v_value := to_char(time,''YYYY-MM-DD HH24:MI:SS TZ'')::text from ams_times where value_id = p_value_id;
        return v_value;
end;' language 'plpgsql';



------ AMS 
--------------------------------------------------------------------


create or replace function ams_value__number_save (numeric)
returns integer as '
declare
        p_number        alias for $1;
        v_value_id      integer;
begin

	v_value_id :=  value_id
                        from ams_numbers
                       where number = p_number;

        if v_value_id is null then
                v_value_id := nextval from acs_object_id_seq;
                insert into ams_numbers
                (value_id,number) 
                values
                (v_value_id,p_number);
        end if;

        return v_value_id;
end;' language 'plpgsql';

create or replace function ams_value__number(integer)
returns text as '
declare
        p_value_id    alias for $1;
        v_value       text;
begin
        v_value := number::text from ams_numbers where value_id = p_value_id;
        return v_value;
end;' language 'plpgsql';


------ Lists
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
        p_attribute_id       alias for $2;
        p_sort_order         alias for $3;
        p_required_p         alias for $4;
        p_section_heading    alias for $5;
        v_sort_order         integer;
begin

        if p_sort_order is null then
           v_sort_order := nextval from acs_object_id_seq;
        else
           v_sort_order := p_sort_order;
        end if;

        delete from ams_list_attribute_map
         where attribute_id = p_attribute_id
           and list_id = p_list_id;

        insert into ams_list_attribute_map
                (list_id,attribute_id,sort_order,required_p,section_heading)
        values
                (p_list_id,p_attribute_id,v_sort_order,p_required_p,p_section_heading);

        return ''1'';
end;' language 'plpgsql';





create or replace function ams_list__name (integer)
returns varchar as '
declare
        p_list_id               alias for $1;
        v_name                  varchar;
begin
       v_name := pretty_name from ams_lists where list_id = p_list_id;

       return v_name;
end;' language 'plpgsql';









------ Postal Address
--------------------------------------------------------------------

create or replace function ams_value__postal_address (integer)
returns text as '
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
                           CASE WHEN country_code::varchar is not null THEN country_code::varchar ELSE '''' END  || ''} {'' ||
                           CASE WHEN additional_text is not null THEN additional_text ELSE '''' END || ''} {'' ||
                           CASE WHEN postal_type::text is not null THEN postal_type::text ELSE '''' END || ''}''
                      from postal_addresses
                     where address_id = p_address_id;
        else
                v_name := NULL;
        end if;

        return v_name;
end;' language 'plpgsql';

create or replace function ams_value__postal_address_save (varchar,varchar,varchar,varchar,char(2),varchar,integer)
returns integer as ' 
declare 
        p_delivery_address     alias for $1;
        p_municipality         alias for $2;
        p_region               alias for $3;
        p_postal_code          alias for $4;
        p_country_code         alias for $5;
        p_additional_text      alias for $6;
        p_postal_type          alias for $7;
        v_address_id           integer;
begin 

        if p_additional_text is null and p_postal_type is null then

	v_address_id := address_id
                        from postal_addresses
                       where delivery_address = p_delivery_address
                         and municipality = p_municipality
                         and region = p_region
                         and postal_code = p_postal_code
                         and country_code = p_country_code
                         and additional_text is NULL
                         and postal_type is NULL;

        else 

	v_address_id := address_id
                        from postal_addresses
                       where delivery_address = p_delivery_address
                         and municipality = p_municipality
                         and region = p_region
                         and postal_code = p_postal_code
                         and country_code = p_country_code
                         and additional_text = p_additional_text
                         and postal_type = p_postal_type;
        
        end if;

        if v_address_id is null then

                v_address_id := acs_object__new (  
	                null,  
	                ''postal_address'',
	                now(), 
	                NULL, 
	                NULL,
	                NULL
	        );
	
	        insert into postal_addresses 
	        ( address_id, delivery_address, municipality, region, postal_code, country_code, additional_text, postal_type )  
	        values
	        ( v_address_id, p_delivery_address, p_municipality, p_region, p_postal_code, p_country_code, p_additional_text, p_postal_type );
	
	end if;

        return v_address_id;
end;' language 'plpgsql';



------ Telecom Number
--------------------------------------------------------------------


create or replace function ams_value__telecom_number (integer)
returns text as '
declare
        p_number_id     alias for $1;
        v_name          text;
begin

        if p_number_id is not null then
                v_name :=  ''{'' || 
                  CASE WHEN itu_id::text is not null THEN itu_id::text ELSE '''' END || ''} {'' || 
                  CASE WHEN national_number is not null THEN national_number ELSE '''' END || ''} {'' || 
                  CASE WHEN area_city_code is not null THEN area_city_code ELSE '''' END  || ''} {'' || 
                  CASE WHEN subscriber_number is not null THEN subscriber_number ELSE '''' END  || ''} {'' ||
                  CASE WHEN extension is not null THEN extension ELSE '''' END  || ''} {'' ||
                  CASE WHEN sms_enabled_p is not null THEN CASE WHEN sms_enabled_p THEN ''1'' ELSE ''0'' END ELSE '''' END || ''} {'' ||
                  CASE WHEN best_contact_time is not null THEN best_contact_time ELSE '''' END || ''} {'' ||
                  CASE WHEN location is not null THEN location ELSE '''' END || ''} {'' ||
                  CASE WHEN phone_type_id::text is not null THEN phone_type_id::text ELSE '''' END || ''}''
             from telecom_numbers
             where number_id = p_number_id;
        else
                v_name := NULL;
        end if;

        return v_name;
end;' language 'plpgsql';

create or replace function ams_value__telecom_number_save (integer,varchar,varchar,varchar,varchar,boolean,varchar,varchar,integer)
returns integer as '
declare 
        p_itu_id               alias for $1;
        p_national_number      alias for $2;
        p_area_city_code       alias for $3;
        p_subscriber_number    alias for $4;
        p_extension            alias for $5;
        p_sms_enabled_p        alias for $6;
        p_best_contact_time    alias for $7;
        p_location             alias for $8;
        p_phone_type_id        alias for $9;
        v_number_id            integer;
begin 

	v_number_id := number_id
                        from telecom_numbers
                       where itu_id = p_itu_id
                         and national_number = p_national_number
                         and area_city_code = p_area_city_code
                         and subscriber_number = p_subscriber_number
                         and extension = p_extension
                         and sms_enabled_p = p_sms_enabled_p
                         and best_contact_time = p_best_contact_time
                         and location = p_location
                         and p_phone_type_id = p_phone_type_id;

        if v_number_id is null then

                v_number_id := acs_object__new (  
	                null,  
	                ''telecom_number'',
	                now(), 
	                NULL, 
	                NULL,
	                NULL
	        );
	
	        insert into telecom_numbers 
	        ( number_id, itu_id, national_number, area_city_code, subscriber_number, extension, sms_enabled_p, best_contact_time, location, phone_type_id )
	        values
                ( v_number_id, p_itu_id, p_national_number, p_area_city_code, p_subscriber_number, p_extension, p_sms_enabled_p, p_best_contact_time, p_location, p_phone_type_id);

	end if;

        return v_number_id;
end;' language 'plpgsql';



















