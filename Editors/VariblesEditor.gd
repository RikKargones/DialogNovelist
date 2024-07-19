extends VBoxContainer

enum VARIBLE_TYPES {BOOL, NUMBER, STRING, SIGNAL}

onready var search_line		= $Settings/SearchLine
onready var type_selector	= $Settings/TypeMenu
onready var varibles_list 	= $Scroll/VariblesList
onready var type_menu		= $Settings/TypeMenu

var pck_bool_edit 	= preload("res://EditorsElements/VariblesEditor/Bool.tscn")
var pck_string_edit = preload("res://EditorsElements/VariblesEditor/String.tscn")
var pck_number_edit	= preload("res://EditorsElements/VariblesEditor/Number.tscn")
var pck_signal_edit = preload("res://EditorsElements/VariblesEditor/Signal.tscn")

signal search_call(search_text)


func _ready():
	type_menu.update_items(VARIBLE_TYPES.keys() + ["ALL"])
	type_menu.select_item("ALL")


func add_element(element : EditVaribleBase, varible_name : String) -> void:
	var container = PanelContainer.new()
	container.add_child(element)
	varibles_list.add_child(container)
	element.set_track_varible(varible_name)
	
	connect("search_call", element, "search_call")
	element.connect("visibility_changed", self, "on_element_vibility_change", [element, container])
	element.connect("tree_exited", container, "queue_free")
	call_search()
	
	if !element.visible:
		var warning_popup = ConfirmPopup.new("Varible aded, but not visible due search conditions.")
		Ui.add_popup(warning_popup)


func add_bool(varible_name : String) -> void:
	VariblesData.add_varible(varible_name, false)
	add_element(pck_bool_edit.instance(), varible_name)
	
	
func add_number(varible_name : String) -> void:
	VariblesData.add_varible(varible_name, 0)
	add_element(pck_number_edit.instance(), varible_name)


func add_string(varible_name : String) -> void:
	VariblesData.add_varible(varible_name, "")
	add_element(pck_string_edit.instance(), varible_name)


func add_signal(signal_name : String) -> void:
	VariblesData.add_signal(signal_name, [])
	add_element(pck_signal_edit.instance(), signal_name)


func call_search() -> void:
	match type_menu.get_selected_item():
		VARIBLE_TYPES.BOOL:
			emit_signal("search_call", search_line.get_current_search_text(), false)
		VARIBLE_TYPES.NUMBER:
			emit_signal("search_call", search_line.get_current_search_text(), 0)
		VARIBLE_TYPES.STRING:
			emit_signal("search_call", search_line.get_current_search_text(), "")
		VARIBLE_TYPES.SIGNAL:
			emit_signal("search_call", search_line.get_current_search_text(), [])
		_:
			emit_signal("search_call", search_line.get_current_search_text())


func on_element_vibility_change(element : EditVaribleBase, container : PanelContainer) -> void:
	container.visible = element.visible


func _on_AddBoolBt_pressed():
	var connect_info = Ui.ConnectInfo.new(self, "add_bool")
	Ui.popup_namer(connect_info, "Name bool varible", VariblesData.get_varibles_and_signals_list(), "", true)


func _on_AddNumBt_pressed():
	var connect_info = Ui.ConnectInfo.new(self, "add_number")
	Ui.popup_namer(connect_info, "Name number varible", VariblesData.get_varibles_and_signals_list(), "", true)


func _on_AddStringBt_pressed():
	var connect_info = Ui.ConnectInfo.new(self, "add_string")
	Ui.popup_namer(connect_info, "Name string varible", VariblesData.get_varibles_and_signals_list(), "", true)


func _on_AddSignalBt_pressed():
	var connect_info = Ui.ConnectInfo.new(self, "add_signal")
	Ui.popup_namer(connect_info, "Name signal", VariblesData.get_varibles_and_signals_list(), "", true)


func _on_SearchLine_search_entered(_search_text : String):
	call_search()


func _on_TypeMenu_item_index_selected(_item_index : int):
	call_search()
