<master>

<property name="title">@title@</property>
<property name="context">@context@</property>

<p><strong>#ams.Attribute_Name#</strong> @attribute_info.attribute_name@ 
<p><strong>#ams.Pretty_Name#</strong> @attribute_info.pretty_name@ <if @pretty_name_url@ not nil><a href="@pretty_name_url@"><img src="/shared/images/Edit16.gif" height="16" width="16" alt="Edit" border="0"></a></if></p>
<p><strong>#ams.Pretty_Plural#</strong> @attribute_info.pretty_plural@ <if @pretty_name_url@ not nil><a href="@pretty_plural_url@"><img src="/shared/images/Edit16.gif" height="16" width="16" alt="Edit" border="0"></a></if></p>
<p><strong>#ams.Help_text#</strong> @attribute_info.help_text@<a href="@help_text_url@"><img src="/shared/images/Edit16.gif" height="16" width="16" alt="Edit" border="0"></a></if></p>
<p><strong>#ams.Widget#</strong> <a href="widgets">@attribute_info.widget@</a></p>

<if @options:rowcount@ gt 0>
<listtemplate name="options"></listtemplate>
</if>
