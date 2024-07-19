extends PanelContainer

class_name EditOptionUi

onready var opt_name 		= $List/Settings/OptionName
onready var del_bt			= $List/Settings/DelBt
onready var def_bt			= $List/DefalutBt

onready var bool_select		= $List/ConditionEdit/Pastes/Bools
onready var numb_select		= $List/ConditionEdit/Pastes/Numbers
onready var str_select		= $List/ConditionEdit/Pastes/Strings
onready var condition_edit	= $List/ConditionEdit/Edit

onready var hide_line		= $List/HideLine
onready var hide_bt			= $List/HideLine/HideButton
onready var condition_vbox	= $List/ConditionEdit

onready var warning_icon	= $List/HideLine/WarningIcon

var ignore_selectors	= false
var on_set 				= false
var last_position 		= Vector2()

var timer : SceneTreeTimer

signal option_name_changed(new_name)
signal conditions_edited(conditions)
signal conditions_parse_result_gained(is_parsed)
signal option_set_as_defalut
signal option_deleted


func _ready():
	VariblesData.connect("varible_aded", self, "update_colors")
	VariblesData.connect("varible_deleted", self, "update_colors")
	VariblesData.connect("varible_renamed", self, "update_colors")
	
	bool_select.connect("list_updated", self, "on_list_update")
	numb_select.connect("list_updated", self, "on_list_update")
	str_select.connect("list_updated", self, "on_list_update")
	
	bool_select.connect_to_unicdict(VariblesData.bool_dict)
	numb_select.connect_to_unicdict(VariblesData.number_dict)
	str_select.connect_to_unicdict(VariblesData.string_dict)
	
	update_colors()


func _exit_tree():
	if is_instance_valid(timer): timer.disconnect("timeout", self, "check_condition")
	
	
func update_colors(_one_var_name : String = "", _other_var_name : String = "") -> void:
	condition_edit.clear_colors()
	
	for var_name in VariblesData.get_varibles_list():
		condition_edit.add_keyword_color(var_name, Color.lightblue)


func set_text(new_text : String) -> void:
	on_set = true
	opt_name.text = new_text
	on_set = false
	
	
func set_conditions(conditions_line : String) -> void:
	on_set = true
	condition_edit.text = conditions_line
	on_set = false

	
func set_as_defalut(on : bool) -> void:
	def_bt.visible = !on
	del_bt.visible = !on
	hide_line.visible = !on
	if !on: condition_vbox.visible = !hide_bt.is_hide
	else: condition_vbox.visible = false
	

func _on_OptionName_text_changed(new_text : String) -> void:
	if on_set: return
	
	emit_signal("option_name_changed", new_text)


func _on_DefalutBt_pressed() -> void:
	set_as_defalut(true)
	emit_signal("option_set_as_defalut")


func _on_DelBt_pressed() -> void:
	emit_signal("option_deleted")
	queue_free()


func on_list_update() -> void:
	ignore_selectors = true


func insert_text_at_cursor(text : String) -> void:
	#condition_edit.call_deferred("grab_focus")
	condition_edit.insert_text_at_cursor(" " + text + " ")


func _on_Bools_item_selected(item_name : String) -> void:
	if ignore_selectors: ignore_selectors = false
	elif VariblesData.has_varible(item_name): insert_text_at_cursor(item_name)


func _on_Numbers_item_selected(item_name : String) -> void:
	if ignore_selectors: ignore_selectors = false
	elif VariblesData.has_varible(item_name): insert_text_at_cursor(item_name)


func _on_Strings_item_selected(item_name : String) -> void:
	if ignore_selectors: ignore_selectors = false
	elif VariblesData.has_varible(item_name): insert_text_at_cursor(item_name)


func _on_Edit_text_changed() -> void:
	if on_set: return
	
	last_position = Vector2(condition_edit.cursor_get_column(), condition_edit.cursor_get_line())
	
	emit_signal("conditions_edited", condition_edit.text)
	
	if is_instance_valid(timer): timer.disconnect("timeout", self, "check_condition")
	
	timer = get_tree().create_timer(1.0)
	timer.connect("timeout", self, "check_condition")
	
	
func check_condition() -> void:
	var express 		= Expression.new()
	var parse_result 	= express.parse("return_boolean(" + condition_edit.text + ")") == OK || condition_edit.text.strip_edges() == ""
	
	warning_icon.visible 		= !parse_result
	warning_icon.hint_tooltip 	= "Condition parsing failed:\n" + express.get_error_text()
	
	if parse_result: emit_signal("conditions_parse_result_gained", "")
	else: emit_signal("conditions_parse_result_gained", express.get_error_text())
