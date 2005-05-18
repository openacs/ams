<master>
<property name="title">@title@</property>
<property name="context">@context@</property>



<p>
<if @return_url_label@ not nil and @return_url@ not nil>
<a href="@return_url@" class="button">@return_url_label@</a>
</if>
<a href="list-form-preview?list_id=@list_id@" class="button">Preview Input Form</a>
</p>

<p><strong>Package Key:</strong> @package_key@</p>
<p><strong>Object Type:</strong> <a href="object?object_type=@object_type@">@object_type@</a></p>
<p><strong>List Name:</strong> @list_name@</p>

<h3>Mapped Attributes</h3>

<listtemplate name="mapped_attributes"></listtemplate>


<h3>Unmapped Attributes</h3>

<listtemplate name="unmapped_attributes"></listtemplate>

<ul class="action-links">
  <li><a href="@create_attribute_url@">Create and map a new attribute</a></li>
  <li><a href="@code_url@">Export code to recreate this list</a>
</ul>
