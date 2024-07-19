extends Resource

class_name DialogState

var dialog_name			: String
var current_node 		: String
var in_minimalist_mode	: bool


func _init(dialog : String, node : String, minimalist_mode : bool) -> void:
	dialog_name = dialog
	current_node = node
	in_minimalist_mode = minimalist_mode
