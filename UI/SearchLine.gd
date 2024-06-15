extends HBoxContainer

onready var label 	= $Label
onready var search 	= $SearchEdit

signal search_entered(search_text)

func _ready():
	search.connect("text_changed", self, "call_search")

	
func call_search(search_text : String) -> void:
	emit_signal("search_entered", search_text)


func get_current_search_text() -> String:
	return search.text.strip_edges()
