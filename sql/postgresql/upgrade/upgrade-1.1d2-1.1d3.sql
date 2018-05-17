-- 
-- packages/ams/sql/postgresql/upgrade/upgrade-1.1d1-1.1d2.sql
-- 
-- @author Malte Sussdorff (sussdorff@sussdorff.de)
-- @creation-date 2005-08-15
-- @arch-tag: 8da2f2cc-356f-400d-bbdd-9795acbf6190
-- @cvs-id $Id$
--

select define_function_args('ams_option__new','option_id,attribute_id,option,sort_order,deprecated_p;f,creation_date,creation_user,creation_ip,context_id,pretty_name');

create or replace function ams_option__new (integer,integer,varchar,integer,boolean,timestamptz,integer,varchar,integer,varchar)
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
        p_pretty_name           alias for $10;
        v_option_id             integer;
        v_sort_order            integer;
begin

        v_option_id := acs_object__new (
                p_option_id,
                ''ams_option'',
                p_creation_date,
                p_creation_user,
                P_creation_ip,
                p_context_id,
		''t'',
		p_pretty_name
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

