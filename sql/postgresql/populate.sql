--
-- packages/ams/sql/postgresql/populate.sql
--
-- @author Matthew Geddert openacs@geddert.com
-- @creation-date 2004-09-07
-- @cvs-id $Id$
--
--

insert into ams_storage_types ( storage_type ) values ( 'telecom_number' );
insert into ams_storage_types ( storage_type ) values ( 'postal_address' );
insert into ams_storage_types ( storage_type ) values ( 'ams_options' );
insert into ams_storage_types ( storage_type ) values ( 'time' );
insert into ams_storage_types ( storage_type ) values ( 'value' );
insert into ams_storage_types ( storage_type ) values ( 'value_with_mime_type' );

-- 
-- Note, I am very open to adding new unique widgets.
-- I am simply adding those I personally could imagine
-- needing in the near future for my projects. I am sure
-- that there will be others that other programmers need.
-- So, If you would like a new widget and possibly a new
-- storage type added to the default configuration of
-- this package please contact me.
--                                    -- Matthew
--

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'postal_address',
        '#ams.Address#',
        '#ams.Addresses#',
        'postal_address',
        'string',
        'address',
        'address',
        null
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'telecom_number',
        '#ams.Telecom_Number#',
        '#ams.Telecom_Numbers#',
        'telecom_number',
        'string',
        'telecom_number',
        'telecom_number',
        '{html {size 12 maxlenth 50}}'
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'date',
        '#ams.Date#',
        '#ams.Date#',
        'time',
        'date',
        'date',
        'date',
        '{help}'
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'select',
        '#ams.Select# - #ams.One_Option_Allowed#',
        '#ams.Selects# - #ams.One_Option_Allowed#',
        'ams_options',
        'string',
        'select',
        'integer',
        null
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'radio',
        '#ams.Radio# - #ams.One_Option_Allowed#',
        '#ams.Radios# - #ams.One_Option_Allowed#',
        'ams_options',
        'string',
        'radio',
        'integer',
        null
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'checkbox',
        '#ams.Checkboxes# - #ams.Multiple_Options_Allowed#',
        '#ams.Checkboxes# - #ams.Multiple_Options_Allowed#',
        'ams_options',
        'string',
        'checkbox',
        'integer',
        '{multiple}'
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'multiselect',
        '#ams.Multiselect# - #ams.Multiple_Options_Allowed#',
        '#ams.Multiselects# - #ams.Multiple_Options_Allowed#',
        'ams_options',
        'string',
        'multiselect',
        'integer',
        '{multiple}'
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'multiselect_single',
        '#ams.Multiselect# - #ams.One_Option_Allowed#',
        '#ams.Multiselects# - #ams.One_Option_Allowed#',
        'ams_options',
        'string',
        'multiselect',
        'integer',
        null
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'integer',
        '#ams.Integer#',
        '#ams.Integers#',
        'value',
        'integer',
        'text',
        'integer',
        '{html {size 6}}'
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'textbox_small',
        '#ams.Textbox# - #ams.Small#',
        '#ams.Textboxes# - #ams.Small#',
        'value',
        'string',
        'text',
        'text',
        '{html {size 18}}'
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'textbox_medium',
        '#ams.Textbox# - #ams.Medium#',
        '#ams.Textboxes# - #ams.Medium#',
        'value',
        'string',
        'text',
        'text',
        '{html {size 30}}'
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'textbox_large',
        '#ams.Textbox# - #ams.Large#',
        '#ams.Textboxes# - #ams.Large#',
        'value',
        'string',
        'text',
        'text',
        '{html {size 50}}'
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'textarea_small',
        '#ams.Textarea# - #ams.Small#',
        '#ams.Textareas# - #ams.Small#',
        'value',
        'text',
        'textarea',
        'text',
        '{html {cols 60 rows 6}}'
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'textarea_small_nospell',
        '#ams.Textarea# - #ams.Small# - #ams.No_Spellcheck#',
        '#ams.Textareas# - #ams.Small# - #ams.No_Spellcheck#',
        'value',
        'text',
        'textarea',
        'text',
        '{html {cols 60 rows 6}} {nospell}'
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'textarea_medium',
        '#ams.Textarea# - #ams.Medium#',
        '#ams.Textareas# - #ams.Medium#',
        'value',
        'text',
        'textarea',
        'text',
        '{html {cols 80 rows 10}}'
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'textarea_large',
        '#ams.Textarea# - #ams.Large#',
        '#ams.Textareas# - #ams.Large#',
        'value',
        'text',
        'textarea',
        'text',
        '{html {cols 80 rows 24}}'
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'richtext_medium',
        '#ams.Richtext# - #ams.Medium#',
        '#ams.Richtexts# - #ams.Medium#',
        'value_with_mime_type',
        'text',
        'richtext',
        'richtext',
        '{html {cols 80 rows 10}}'
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'richtext_large',
        '#ams.Richtext# - #ams.Large#',
        '#ams.Richtexts# - #ams.Large#',
        'value_with_mime_type',
        'text',
        'richtext',
        'richtext',
        '{html {cols 80 rows 24}}'
);


insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'email',
        '#ams.Email_Address#',
        '#ams.Email_Addresses#',
        'value',
        'email',
        'text',
        'email',
        '{html {size 30}}'
);

insert into ams_widgets (
        widget_name,
        pretty_name,
        pretty_plural,
        storage_type,
        acs_datatype,
        widget,
        datatype,
        parameters
) values (
        'url',
        '#ams.Url#',
        '#ams.Urls#',
        'value',
        'url',
        'text',
        'url',
        '{html {size 30}}'
);



