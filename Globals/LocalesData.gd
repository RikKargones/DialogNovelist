extends Node

const LocalesNames = {
	"ar" : "Arabic",
		"ar_AE" : "Arabic (United Arab Emirates)", "ar_BH" : "Arabic (Bahrain)", "ar_DZ" : "Arabic (Algeria)",
		"ar_EG" : "Arabic (Egypt)",	"ar_IQ" : "Arabic (Iraq)","ar_JO" : "Arabic (Jordan)", "ar_KW" : "Arabic (Kuwait)",
		"ar_LB" : "Arabic (Lebanon)", "ar_LY" : "Arabic (Libya)", "ar_MA" : "Arabic (Morocco)",	"ar_OM" : "Arabic (Oman)",
		"ar_QA" : "Arabic (Qatar)", "ar_SA" : "Arabic (Saudi Arabia)", "ar_SD" : "Arabic (Sudan)", "ar_SY" : "Arabic (Syria)",
		"ar_TN" : "Arabic (Tunisia)", "ar_YE" : "Arabic (Yemen)",
	"be" : "Belarusian",
	"bg" : "Bulgarian",
	"ca" : "Catalan",
	"cs" : "Czech",
	"da" : "Danish",
	"de" : "German",
		"de_AT" : "German (Austria)", "de_CH" : "German (Switzerland)", "de_DE" : "German (Germany)", "de_LU" : "German (Luxembourg)",
	"el" : "Greek",
		"el_CY" : "Greek (Cyprus)", "el_GR" : "Greek (Greece)",
	"en" : "English",
		"en_AU" : "English (Australia)", "en_CA" : "English (Canada)", "en_GB" : "English (United Kingdom)", "en_IE" : "English (Ireland)",
		"en_IN" : "English (India)", "en_MT" : "English (Malta)", "en_NZ" : "English (New Zealand)", "en_PH" : "English (Philippines)",
		"en_SG" : "English (Singapore)", "en_US" : "English (United States)", "en_ZA" : "English (South Africa)",
	"es" : "Spanish",
		"es_AR" : "Spanish (Argentina)", "es_BO" : "Spanish (Bolivia)", "es_CL" : "Spanish (Chile)", "es_CO" : "Spanish (Colombia)",
		"es_CR" : "Spanish (Costa Rica)", "es_DO" : "Spanish (Dominican Republic)", "es_EC" : "Spanish (Ecuador)",
		"es_ES" : "Spanish (Spain)", "es_GT" : "Spanish (Guatemala)", "es_HN" : "Spanish (Honduras)", "es_MX" : "Spanish (Mexico)",
		"es_NI" : "Spanish (Nicaragua)", "es_PA" : "Spanish (Panama)", "es_PE" : "Spanish (Peru)", "es_PR" : "Spanish (Puerto Rico)",
		"es_PY" : "Spanish (Paraguay)", "es_SV" : "Spanish (El Salvador)", "es_US" : "Spanish (United States)", "es_UY" : "Spanish (Uruguay)",
		"es_VE" : "Spanish (Venezuela)",
	"et" : "Estonian",
	"fi" : "Finnish",
	"fr" : "French",
		"fr_BE" : "French (Belgium)", "fr_CA" : "French (Canada)", "fr_CH" : "French (Switzerland)", "fr_FR" : "French (France)",
		"fr_LU" : "French (Luxembourg)",
	"ga" : "Irish",
	"hi" : "Hindi (India)",
	"hr" : "Croatian",
	"hu" : "Hungarian",
	"in" : "Indonesian",
	"is" : "Icelandic",
	"it" : "Italian",
		"it_CH" : "Italian (Switzerland)", "it_IT" : "Italian (Italy)",
	"iw" : "Hebrew",
	"ja" : "Japanese",
		"ja_JP" : "Japanese (Japan)", "ja_JP_JP" : "Japanese (Japan,JP)",
	"ko" : "Korean",
	"lt" : "Lithuanian",
	"lv" : "Latvian",
	"mk" : "Macedonian",
	"ms" : "Malay",
	"mt" : "Maltese",
	"nl" : "Dutch",
		"nl_BE" : "Dutch (Belgium)", "nl_NL" : "Dutch (Netherlands)",
	"no" : "Norwegian",
		"no_NO" : "Norwegian (Norway)", "no_NO_NY" : "Norwegian (Norway,Nynorsk)",
	"pl" : "Polish",
	"pt" : "Portuguese",
		"pt_BR" : "Portuguese (Brazil)", "pt_PT" : "Portuguese (Portugal)",
	"ro" : "Romanian",
	"ru" : "Russian",
	"sk" : "Slovak",
	"sl" : "Slovenian",
	"sq" : "Albanian",
	"sr" : "Serbian",
		"sr_BA" : "Serbian (Bosnia and Herzegovina)", "sr_CS" : "Serbian (Serbia and Montenegro)", "sr_ME" : "Serbian (Montenegro)",
		"sr_RS" : "Serbian (Serbia)",
	"sv" : "Swedish",
	"th" : "Thai",
		"th_TH" : "Thai (Thailand)", "th_TH_TH" : "Thai (Thailand,TH)",
	"tr" : "Turkish",
	"uk" : "Ukrainian",
	"vi" : "Vietnamese",
	"zh" : "Chinese",
		"zh_CN" : "Chinese (China)", "zh_HK" : "Chinese (Hong Kong)", "zh_SG" : "Chinese (Singapore)", 	"zh_TW" : "Chinese (Taiwan)",
	}


class EditorLangInfo extends DialogDispetcher.LangInfo:
	func _init(lang_short : String, def_font_name = ""):		
		if LocalesNames.has(lang_short): translation_res.locale = lang_short
		defalut_font_name = def_font_name
		
	func update_msg_list(msg_list : PoolStringArray) -> void:
		for old_msg in translation_res.get_message_list():
			if old_msg in msg_list: continue
			translation_res.erase_message(old_msg)
			
		for msg in msg_list:
			if msg in translation_res.get_message_list(): continue
			
			translation_res.add_message(msg, "")
	
	func rename_msg(old_msg_name : String, new_msg_name : String) -> void:
		if !old_msg_name in translation_res.get_message_list() || new_msg_name in translation_res.get_message_list(): return
		
		var old_msg_text = translation_res.get_message(old_msg_name)
		translation_res.add_message(new_msg_name, old_msg_text)
		translation_res.erase_message(old_msg_name)
	
	func set_msg(msg_name : String, msg : String) -> void:
		translation_res.add_message(msg_name, msg)


var locale_dict 	: DialogDispetcher.UnicDict 	= DialogDispetcher.UnicDict.new()
var msg_list		: Array 						= []
var defalut_locales : Array							= ["en", "ru"]


signal msg_list_updated(upadated_msg_list)


func _ready():
	setup()


func setup():
	locale_dict.clear()
	return_defults()


func return_defults() -> void:
	for def_locale in defalut_locales:
		add_locale(def_locale)


func has_locale_msg(msg_key : String) -> bool:
	return msg_list.has(msg_key)


func get_locale_long(locale_short : String) -> String:
	if !locale_short in LocalesNames.keys(): return ""
	return LocalesNames[locale_short]


func get_locale(locale_long : String) -> EditorLangInfo:
	return locale_dict.get_value(locale_long)
	

func get_locale_msg_text(locale_long : String, msg_key : String) -> String:
	if !has_locale_msg(msg_key): return ""
	
	var locale = get_locale(locale_long)
	
	if !is_instance_valid(locale): return ""
	
	return locale.translation_res.get_message(msg_key)


func get_locale_defalut_font(locale_long : String) -> String:
	if !locale_dict.has(locale_long): return ""
	
	return get_locale(locale_long).defalut_font_name


func add_locale(locale_short : String, font_name = "") -> void:
	if !locale_short in LocalesNames.keys(): return
	
	var new_locale = EditorLangInfo.new(locale_short)
	
	new_locale.update_msg_list(msg_list)
	connect("msg_list_updated", new_locale, "update_msg_list")
	
	locale_dict.add_key(get_locale_long(locale_short), new_locale)
	
	if font_name != "": set_locale_defalut_font(get_locale_long(locale_short), font_name)


func add_locales_msg(msg_key : String, defalut = "") -> void:
	if has_locale_msg(msg_key): return
	
	msg_list.append(msg_key)
	
	emit_signal("msg_list_updated", msg_list)
	
	for locale in locale_dict.keys():
		set_locale_msg(locale, msg_key, defalut)


func rename_locale_msg(old_msg_key : String, new_msg_key : String) -> void:
	if !has_locale_msg(old_msg_key) && has_locale_msg(new_msg_key): return
	
	for locale in locale_dict.keys():
		get_locale(locale).rename_msg(old_msg_key, new_msg_key)


func set_locale_msg(locale_long : String, msg_key : String, msg : String) -> void:
	if !locale_dict.has(locale_long): return
	
	var trans : EditorLangInfo = get_locale(locale_long)
	
	trans.set_msg(msg_key, msg)


func set_locale_defalut_font(locale_long : String, font_name : String) -> void:
	var lang_info 	: EditorLangInfo			= get_locale(locale_long)
	var font_info	: FontsData.EditorFontInfo 	= FontsData.get_fontinfo(font_name)
	
	if !is_instance_valid(lang_info): return
	
	if !is_instance_valid(font_info): lang_info.defalut_font_name = ""
	else: lang_info.defalut_font_name = font_name	


func erase_locales_msg(msg_key : String) -> void:
	if !has_locale_msg(msg_key): return
	
	msg_list.erase(msg_key)
	
	emit_signal("msg_list_updated", msg_list)
	
	
func erase_locale(locale_long : String) -> void:
	if locale_long == LocalesNames.en || locale_long == LocalesNames.ru: return
	
	locale_dict.erase(locale_long)
	
	
