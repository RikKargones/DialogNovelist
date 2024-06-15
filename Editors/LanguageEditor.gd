extends VBoxContainer

onready var list 	= $ScrollContainer/List

var locale_setting_pck = preload("res://UI/EditorsElements/LangluageElement.tscn")

signal search_call(search_text)

func _ready():
	for locale in LocalesData.LocalesNames.keys():
		var new_locale_ui = locale_setting_pck.instance()
		list.add_child(new_locale_ui)
		new_locale_ui.set_locale(locale)
		connect("search_call", new_locale_ui, "search_call")
		
	get_tree().root.connect("size_changed", self, "on_item_rect_change")
	on_item_rect_change()


func on_item_rect_change():
	var columns = 1
	
	while 400 * (columns + 1) < OS.window_size.x:
		columns += 1
	
	list.columns = columns


func _on_SearchLine_search_entered(search_text : String) -> void:
	emit_signal("search_call", search_text)
