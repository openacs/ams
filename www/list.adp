<master>
<property name="title">@title@</property>
<property name="context">@context@</property>



<p>
<if @return_url_label@ not nil and @return_url@ not nil>
<a href="@return_url@" class="button">@return_url_label@</a>
</if>
<a href="list-form-preview?list_id=@list_id@" class="button">#ams.Preview_Input_Form#</a>
</p>

<p><strong>#ams.Package_Key#</strong> @package_key@</p>
<p><strong>#ams.Object_Type#</strong> <a href="object?object_type=@object_type@">@object_type@</a></p>
<p><strong>#ams.List_Name#</strong> @list_name@</p>

<h3>#ams.Mapped_Attributes#</h3>

<listtemplate name="mapped_attributes"></listtemplate>


<h3>#ams.Unmapped_Attributes#</h3>

<listtemplate name="unmapped_attributes"></listtemplate>

<ul class="action-links">
  <li><a href="@create_attribute_url@">#ams.lt_Create_and_map_a_new_#</a></li>
  <li><a href="@code_url@">#ams.lt_Export_code_to_recrea#</a>
</ul>

