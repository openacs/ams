-- 
-- packages/ams/sql/postgresql/upgrade/upgrade-1.1d1-1.1d2.sql
-- 
-- @author Malte Sussdorff (sussdorff@sussdorff.de)
-- @creation-date 2005-08-15
-- @arch-tag: 8da2f2cc-356f-400d-bbdd-9795acbf6190
-- @cvs-id $Id$
--

create index ams_attribute_values_attribute_idx on ams_attribute_values(attribute_id);