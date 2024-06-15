extends Node

var current_edit_locale 	: String = LocalesData.LocalesNames.en
var translate_edit_locale 	: String = LocalesData.LocalesNames.ru


func set_current_edit_locale(locale : String) -> void:
	if LocalesData.locale_dict.has(locale): current_edit_locale = locale
	
	
func set_translate_edit_locale(locale : String) -> void:
	if LocalesData.locale_dict.has(locale): translate_edit_locale = locale	
