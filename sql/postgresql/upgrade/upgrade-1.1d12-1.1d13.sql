-- 
-- packages/ams/sql/postgresql/upgrade/upgrade-1.1d12-1.1d13.sql
-- 
-- @author Matthew Geddert (openacs@geddert.com)
-- @creation-date 2006-01-30
-- @arch-tag: 
-- @cvs-id $Id$
--


create or replace function ams_attribute_value__value_by_object_id (integer,integer)
returns text as '
declare
  p_attribute_id           alias for $1;
  p_object_id              alias for $2;  
  v_value                  text;
begin
  val := ams_attribute_value__value(p_attribute_id,( select aav.value_id from ams_attribute_values aav where aav.object_id = p_object_id and aav.attribute_id = p_attribute_id));

  return v_value;
end;' language 'plpgsql' stable strict;


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
                         and postal_type is NULL
                       limit 1;

        else 

	v_address_id := address_id
                        from postal_addresses
                       where delivery_address = p_delivery_address
                         and municipality = p_municipality
                         and region = p_region
                         and postal_code = p_postal_code
                         and country_code = p_country_code
                         and additional_text = p_additional_text
                         and postal_type = p_postal_type
                       limit 1;
        
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
