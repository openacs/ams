<master>
<property name="title">@title@</property>
<property name="context">@context@</property>

<h3>This is currently a testing page for the save and retrieval procs</h3>

<pre>
@attr_list@
</pre>



<formtemplate id="entry"></formtemplate>


<if @lists:rowcount@ gt 0>
    <ul>
      <multiple name="lists">
      <li>@lists.first_names@ @lists.last_name@ @lists.middle_names@
      </multiple>
    </ul>
</if>
