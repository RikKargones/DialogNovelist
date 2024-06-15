extends HBoxContainer

class_name EditVaribleBase

var name_label 	: Label 	= Label.new()
var delete_bt 	: Button 	= Button.new()
var rename_bt 	: Button 	= Button.new()

var varible_name = ""

signal varible_edited(value)
signal varible_deleted


func _ready():
	var sep_one = VSeparator.new()
	var sep_two = VSeparator.new()
	
	size_flags_horizontal = SIZE_EXPAND_FILL
	
	name_label.size_flags_vertical 	= SIZE_EXPAND_FILL
	delete_bt.size_flags_vertical 	= 0
	rename_bt.size_flags_vertical 	= 0
	
	delete_bt.text = "Delete"
	rename_bt.text = "Rename"
	
	name_label.rect_min_size.x 	= 100
	name_label.clip_text		= true
	name_label.align 			= Label.ALIGN_CENTER
	name_label.add_font_override("font", preload("res://UI/Fonts/MainEditorFontBold.tres"))
	
	add_child(sep_one)
	add_child(sep_two)
	add_child(rename_bt)
	add_child(delete_bt)
	add_child(name_label)
	
	move_child(name_label, 0)
	move_child(sep_one, 1)
	move_child(rename_bt, 2)
	move_child(delete_bt, 3)
	move_child(sep_two, 4)
	
	rename_bt.connect("pressed", self, "on_rename_bt_press")
	delete_bt.connect("pressed", self, "on_delete_bt_press")


func on_varible_set(var_name : String) -> bool:
	varible_name = var_name
	name_label.text = varible_name
	name_label.hint_tooltip = var_name
	
	if VariblesData.has_varible(var_name):
		emit_signal("varible_edited", VariblesData.get_varible(var_name))
	if VariblesData.has_signal(var_name): return _set_value(VariblesData.get_signal_defalut_data(var_name))
	return _set_value(VariblesData.get_varible(var_name))


func _set_value(value) -> bool:
	return false


func _on_search_call(search_text : String) -> bool:
	return false


func set_track_varible(var_name : String) -> void:
	if (VariblesData.get_varibles_and_signals_list().has(var_name) && on_varible_set(var_name)):
		return
	
	queue_free()


func hide_rename() -> void:
	name_label.visible = false
	rename_bt.visible = false


func search_call(search_text : String, value_example = null) -> void:
	if value_example == null:
		visible = search_text.strip_edges() == "" || varible_name.begins_with(search_text) || _on_search_call(search_text)
	elif !(typeof(value_example) == typeof(VariblesData.get_varible(varible_name)) || value_example is Array):
		visible = false


func delete_confirmed() -> void:
	if VariblesData.has_varible(varible_name): emit_signal("varible_deleted")
	
	VariblesData.erase_varible(varible_name)
	VariblesData.erase_signal(varible_name)
	
	queue_free()


func rename_confirmed(new_name : String) -> void:
	VariblesData.rename_varible(varible_name, new_name)
	VariblesData.rename_signal(varible_name, new_name)
	set_track_varible(new_name)


func on_delete_bt_press() -> void:
	var confirm_popup = ConfirmPopup.new("Are you sure to delete this varible/signal?")
	Ui.add_popup(confirm_popup, "confirmed", self, "delete_confirmed")
	
	
func on_rename_bt_press() -> void:
	var title = "Name "
	
	if VariblesData.has_signal(varible_name): title += "signal"
	else: title += "varible"
	
	var name_popup = NameDialog.new(title, VariblesData.get_varibles_and_signals_list(), "", true)
	Ui.add_popup(name_popup, "name_confurmed", self, "rename_confirmed")
