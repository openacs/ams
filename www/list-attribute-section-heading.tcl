ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$
} {
    {list_id:integer,notnull}
    {attribute_id:integer,notnull}
    return_url:optional
    return_url_label:optional
}

db_0or1row get_heading { select aa.pretty_name as attribute_pretty_name,
                                al.package_key,
                                al.object_type,
                                al.list_name,
                                al.pretty_name as list_pretty_name,
                                alam.section_heading
                           from ams_list_attribute_map alam,
                                ams_attributes aa,
                                ams_lists al
                          where alam.attribute_id = aa.attribute_id
                            and alam.list_id = al.list_id
                            and alam.list_id = :list_id
                            and alam.attribute_id = :attribute_id
}
set title "[_ ams.lt_Add_a_Heading_Above_a]"
set context [list [list lists Lists] [list [ams::list::url -package_key $package_key -object_type $object_type -list_name $list_name] ${list_pretty_name}] $title]

set package_options " [db_list_of_lists select_packages { select package_key, package_key from apm_package_types order by package_key } ]"

ad_form -name list_form -form {
    list_id:integer(hidden)
    attribute_id:integer(hidden)
    {section_heading:text,optional {label "[_ ams.Heading]"} {html {size 40 maxlength 200}}}
    {no_section:integer(checkbox),optional {label ""} {options {{{[_ ams.Heading_Stop]} 1}}}}
    {save:text(submit) {label "[_ acs-kernel.common_Save]"}}
    {delete:text(submit) {label "[_ ams.Delete_Heading]"}}
} -on_request {
    if { $section_heading eq "no_section" } {
	set section_heading ""
	set no_section "1"
    }
} -on_submit {
    set section_heading [string trim $section_heading]
    if { [string is true [exists_and_not_null delete]] } {
	set section_heading ""
    } elseif { $no_section eq "1" } {
	if { $section_heading eq "" } {
	    set section_heading "no_section"
	}
    }
    db_dml update_section_heading {
	update ams_list_attribute_map
	   set section_heading = :section_heading
         where list_id = :list_id
           and attribute_id = :attribute_id
    }
} -after_submit {
    ad_returnredirect "list?[export_vars -url {package_key object_type list_name return_url return_url_label}]"
    ad_script_abort
}

    
ad_return_template
