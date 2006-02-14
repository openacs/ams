ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
}


set title "[_ ams.Widgets]"
set context [list $title]

list::create \
    -name widgets \
    -multirow widgets \
    -key widget_name \
    -row_pretty_plural "[_ ams.Object_Types]" \
    -checkbox_name checkbox \
    -selected_format "normal" \
    -class "list" \
    -main_class "list" \
    -sub_class "narrow" \
    -pass_properties {
        variable
    } -actions {
    } -bulk_actions {
    } -elements {
        widget_name {
            display_col widget_name
            label "[_ ams.Widget_Name]"
        }
        pretty_name {
            display_col pretty_name
            label "[_ ams.Pretty_Name_1]"
        }
        pretty_plural {
            display_col pretty_plural
            label "[_ ams.Pretty_Plural_1]"
        }
        widget {
            display_col widget
            label "[_ ams.Widget_1]"
        }
        datatype {
            display_col datatype
            label "[_ ams.Datatype]"
        }
        parameters {
            display_col parameters
            label "[_ ams.Parameters]"
        }
    } -filters {
        object_type {}
    } -groupby {
    } -orderby {
    } -formats {
        normal {
            label "[_ ams.Table]"
            layout table
            row {
                widget_name {}
                pretty_name {}
                widget {}
                datatype {}
                parameters {}
            }
        }
    }


db_multirow widgets get_widgets {
    select *
      from ams_widgets
     order by pretty_name
} {
}

template::multirow foreach widgets {
    set form_element "${widget_name}_widget:${datatype}(${widget}),optional"
    if { [string equal $storage_type "ams_options"] } {
        append form_element { {options { {"[_ ams.Demo_Example_One]" 1} {"[_ ams.Demo_Example_Two]" 2} {"[_ ams.Demo_Example_Three]" 3} {"[_ ams.Demo_Example_Four]" 4} {"[_ ams.Demo_Example_Five]" 5} {"[_ ams.Demo_Example_Six]" 6} }}}
    }
    if { [exists_and_not_null parameters] } {
        append form_element " ${parameters}"
    }
    lappend form_element [list "label" "<p><strong>$widget_name</strong></p><p>$pretty_plural</p><p><small>widget: $widget<br>datatype: $datatype<br>parameters: $parameters</small></p>"]
    lappend form_elements $form_element
}

ad_form -name widgets_form -form $form_elements -on_submit {}



ad_return_template
