<master>

<property name="title">@title@</property>
<property name="context">@context@</property>

<p><strong>Pretty Name:</strong> @pretty_name@</p>
<p><strong>Pretty Plural:</strong> @pretty_plural@</p>
<p><strong>Widget:</strong> <a href="widgets">@attribute_info.widget_name@</a></p>

<if @attribute_info.storage_type@ eq ams_options>
<listtemplate name="options"></listtemplate>
</if>
