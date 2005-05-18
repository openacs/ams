<master>

<property name="title">@title@</property>
<property name="context">@context@</property>

<p><strong>Pretty Name:</strong> @pretty_name@</p>
<p><strong>Pretty Plural:</strong> @pretty_plural@</p>
<p><strong>Widget:</strong> <a href="widgets">@attribute_info.widget@</a></p>


<if @options:rowcount@ gt 0>
<listtemplate name="options"></listtemplate>
</if>
