extends Node

enum FONT_NAMES		{}
enum VARIBLE_NAMES 	{}
enum SIGNAL_NAMES	{}
enum PERSON_IDS		{}
enum DIALOG_NAMES 	{}

var path_to_data 		: String

var fonts_data 			: Dictionary
var varibles_int_data 	: Dictionary
var varibles_bool_data	: Dictionary
var varibles_str_data	: Dictionary
var person_data 		: Dictionary
var dialogs_data 		: Dictionary

#CUSTOM_SIGNALS

func get_align_name(index : int) -> String:
	if index >= PersonProfile.ALIGN_LIST.keys().size() && index < 0: return ""
	return PersonProfile.ALIGN_LIST.keys()[index]


func get_align_names_list() -> PoolStringArray:
	return PoolStringArray(PersonProfile.ALIGN_LIST.keys())
	
	
func return_boolean(expression : bool) -> bool:
	return expression

