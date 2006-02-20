ad_page_contract {
    Page that allows you to add html_options to an specific
    attribute_id for an specific list_id
    
    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
    @creation-date 2005-11-21
} {
    list_id:integer,notnull
    attribute_id:integer,notnull
    return_url:optional
}

set page_title "[_ ams.Html_options]"
set context [list [list "[get_referrer]" "[_ ams.AMS_Lists]"] $page_title]

if { ![exists_and_not_null return_url] } {
    set return_url [get_referrer]
}

ad_form -name html_options -form {
    {return_url:text(hidden)
	{value $return_url}
    }
    {list_id:text(hidden)
	{value $list_id}
    }
    {attribute_id:text(hidden)
	{value $attribute_id}
    }
    {html_options:text(text),optional
	{label "[_ ams.Html_options]"}
	{html {size 80 maxlength 1000}}
	{help_text "[_ ams.Html_options_help]"}
    }
    {save:text(submit) {label "[_ acs-kernel.common_Save]"}}
    {delete:text(submit) {label "[_ ams.Delete_html]"}}
} -on_request {
    # Get the html_options
    db_0or1row get_html_options { }

} -on_submit {
    if { [string is true [exists_and_not_null delete]] } {
	set html_options ""
    }
    set html_options [string trim $html_options]
    db_dml update_html_options { }
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}

ad_return_template
