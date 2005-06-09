ad_library {
    Initialization for ams.
    
    @creation-date 2005-02-10
    @author Matthew Geddert (openacs@geddert.com)
    @cvs-id $Id$
}

ams::widgets_init

if { [empty_string_p [info procs "::lang::util::convert_to_i18n"]] } {

    ns_log notice "proc ::lang::util::convert_to_i18n not provided by acs-lang because we are using an older version. the proc will be added via ams."

    ad_proc -public lang::util::convert_to_i18n {
	{-locale}
	{-package_key "ams"}
	{-message_key ""}
	{-prefix ""}
	{-text:required}
    } {
	Internationalising of Attributes. This is done by storing the attribute with it's acs-lang key
    } {
	
	if {[empty_string_p $message_key]} {
	    if {[empty_string_p $prefix]} {
	        # Having no prefix or message_key is discouraged as it
	        # might have interesting side effects due to double
	        # meanings of the same english string in multiple contexts
	        # but for the time being we should still allow this.
		set message_key [lang::util::suggest_key $text]
	    } else {
		set message_key "${prefix}_[lang::util::suggest_key $text]"
	    }
	} 
	
	# Register the language keys
	lang::message::register en_US $package_key $message_key $text
	if {[exists_and_not_null locale]} {
	    lang::message::register $locale $package_key $message_key $text
	}
	
	return "\#${package_key}.${message_key}\#"
    }

}
