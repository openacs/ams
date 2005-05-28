<master>
<property name="title">@title@</property>
<property name="context">@context@</property>

<p>#ams.lt_Here_is_the_code_nece#</p>
<pre style="border: 1px solid #CCC; background-color: #EEE; padding: 10px;">
set list_id [ams::list::new \
                -package_key "@list_info.package_key@" \
                -object_type "@list_info.object_type@" \
                -list_name "@list_info.list_name@" \
                -pretty_name "@list_info.pretty_name@" \
                -description "@list_info.description@" \
                -description_mime_type "@list_info.description_mime_type@"]


<if @attributes:rowcount@ gt 0>
<multiple name="attributes">

set attribute_id [attribute::new \
              -object_type "@attributes.object_type@" \
              -attribute_name "@attributes.attribute_name@" \
              -datatype "@attributes.datatype@" \
              -pretty_name "\#@attributes.pretty_name@#" \
              -pretty_plural "\#@attributes.pretty_plural@#" \
              -table_name "@attributes.table_name@" \
              -column_name "@attributes.column_name@" \
              -default_value "@attributes.default_value@" \
              -min_n_values "@attributes.min_n_values@" \
              -max_n_values "@attributes.max_n_values@" \
              -sort_order "@attributes.sort_order@" \
              -storage "@attributes.storage@" \
              -static_p "@attributes.static_p@" \
              -if_does_not_exist]

lang::message::register en_US ams @attributes.message_key@ @attributes.true_pretty@ 
lang::message::register en_US ams @attributes.message_key@_plural @attributes.true_plural@ 

ams::attribute::new \
              -attribute_id $attribute_id \
              -widget "@attributes.widget@" \
              -dynamic_p "@attributes.dynamic_p@"

ams::list::attribute::map \
              -list_id $list_id \
              -attribute_id $attribute_id \
              -sort_order "@attributes.list_sort_order@" \
              -required_p "@attributes.required_p@" \
              -section_heading "@attributes.section_heading@"
</multiple>
</if>
</pre>

