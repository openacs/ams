ad_page_contract {

    @author Matthew Geddert openacs@geddert.com
    @creation-date 2004-07-28
    @cvs-id $Id$


} {
}


set title "Widgets"
set context [list $title]




list::create \
    -name widgets \
    -multirow widgets \
    -key widget_name \
    -row_pretty_plural "Object Types" \
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
            label "Widget Name"
        }
        pretty_name {
            display_col pretty_name
            label "Pretty Name"
        }
        pretty_plural {
            display_col pretty_plural
            label "Pretty Plural"
        }
        widget {
            display_col widget
            label "Widget"
        }
        datatype {
            display_col datatype
            label "Datatype"
        }
        parameters {
            display_col parameters
            label "Parameters"
        }
    } -filters {
        object_type {}
    } -groupby {
    } -orderby {
    } -formats {
        normal {
            label "Table"
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
     order by widget_name
} {
}

template::multirow foreach widgets {
    set form_element "${widget_name}_widget:${datatype}(${widget}),optional"
    if { [string equal $storage_type "ams_options"] } {
        append form_element { {options { {"Demo Example One" 1} {"Demo Example Two" 2} {"Demo Example Three" 3} {"Demo Example Four" 4} {"Demo Example Five" 5} {"Demo Example Six" 6} }}}
    }
    if { [exists_and_not_null parameters] } {
        append form_element " ${parameters}"
    }
    lappend form_element [list "label" "<p><strong>$widget_name</strong></p><p>$pretty_plural</p><p><small>widget: $widget<br>datatype: $datatype<br>parameters: $parameters</small></p>"]
    lappend form_elements $form_element
}

ad_form -name widgets_form -form $form_elements -on_submit {}



ad_return_template
