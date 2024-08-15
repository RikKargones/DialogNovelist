extends Node

enum FONT_NAMES		{}
enum VARIBLE_NAMES 	{}
enum SIGNAL_NAMES	{}
enum PERSON_IDS		{}
enum DIALOG_NAMES 	{}

var fonts_data 			: UnicDict
var varibles_int_data 	: UnicDict
var varibles_bool_data	: UnicDict
var varibles_str_data	: UnicDict
var person_data 		: UnicDict
var dialogs_data 		: UnicDict

#CUSTOM_SIGNALS

func get_align_name(index : int) -> String:
	if index >= PersonProfile.ALIGN_LIST.keys().size() && index < 0: return ""
	return PersonProfile.ALIGN_LIST.keys()[index]


func get_align_names_list() -> PoolStringArray:
	return PoolStringArray(PersonProfile.ALIGN_LIST.keys())
	
	
func return_boolean(expression : bool) -> bool:
	return expression


func get_dialog_data(dialog_idx : int) -> DialogInfo:
	return dialogs_data.get_value(DIALOG_NAMES.keys()[dialog_idx])


func get_person_data(person_idx : int) -> PersonProfile:
	return person_data.get_value(PERSON_IDS.keys()[person_idx])


func get_font_data(font_idx : int) -> FontsData:
	return fonts_data.get_value(FONT_NAMES.keys()[font_idx])

	
func get_varible(var_idx : int):
	var int_rep = varibles_int_data.get_value(VARIBLE_NAMES.keys()[var_idx])
	var str_rep = varibles_str_data.get_value(VARIBLE_NAMES.keys()[var_idx])
	var bol_rep = varibles_bool_data.get_value(VARIBLE_NAMES.keys()[var_idx])
	
	if int_rep is int || int_rep is float: return int_rep
	if str_rep is String: return str_rep
	if bol_rep is bool: return bol_rep
	

