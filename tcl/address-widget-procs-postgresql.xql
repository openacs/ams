<?xml version="1.0"?>
<queryset>


<fullquery name="template::util::address::country_options_not_cached.get_countries">
  <querytext>
        select default_name, iso from countries                                                                                  s
  </querytext>
</fullquery>


<fullquery name="template::data::validate::address.validate_state">
  <querytext>
        select 1 from us_states where abbrev = upper(:region) or state_name = upper(:region)
  </querytext>
</fullquery>


</queryset>
