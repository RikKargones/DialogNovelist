tool
extends HBoxContainer

export var button_suffix = "" setget set_buttons_suffixes

onready var all_section = $All
onready var search_line = $All/Search
onready var list		= $All/Scroll/Items

onready var add_bt		= $All/AddBt
onready var rename_bt	= $All/RenameBt
onready var delete_bt	= $All/DeleteBt

var items			: PoolStringArray = PoolStringArray([])
var blocked_items 	: PoolStringArray = PoolStringArray([])

signal item_selected(item_name)
signal add_item_request
signal rename_item_request(item_name)
signal delete_item_request(item_name)


func get_selected_item() -> String:
	if list.is_anything_selected(): return list.get_item_text(list.get_selected_items()[0])
	return ""


func set_unchangable_items(blocked_list : PoolStringArray) -> void:
	blocked_items = blocked_list
	
	if list.is_anything_selected():
		set_block_on_edit_buttons(get_selected_item() in blocked_items)


func connect_to_unicdict(unic_dict : UnicDict) -> void:
	EditLibraly.disconect_incoming_signals(["key_aded", "key_deleted", "key_renamed", "cleared"], self)
	
	unic_dict.connect("key_aded", self, "on_dict_add", [unic_dict])
	unic_dict.connect("key_deleted", self, "on_dict_delete", [unic_dict])
	unic_dict.connect("key_renamed", self, "on_dict_rename", [unic_dict])
	unic_dict.connect("cleared", self, "on_dict_clear", [unic_dict])
	
	update_list(unic_dict.keys())


func on_dict_add(key : String, unic_dict : UnicDict) -> void:
	update_list(unic_dict.keys(), key)


func on_dict_delete(key : String, unic_dict : UnicDict) -> void:	
	if unic_dict.keys().size() != 0 && key == get_selected_item():
		if list.is_anything_selected():
			var index = list.get_selected_items()[0]
			if index != 0: index -= 1
			update_list(unic_dict.keys(), list.get_item_text(index))
			return
	
	update_list(unic_dict.keys())


func on_dict_rename(old_key : String, new_key : String, unic_dict : UnicDict) -> void:
	if old_key == get_selected_item():
		update_list(unic_dict.keys(), new_key)
		return
	
	update_list(unic_dict.keys())


func on_dict_clear(unic_dict : UnicDict) -> void:
	update_list(unic_dict.keys())


func update_list(by : PoolStringArray, select_name = "") -> void:
	var old_select = get_selected_item()
	var search_text = search_line.get_current_search_text()
	
	list.clear()
	items = by
	select_name = select_name.strip_edges()
	
	for item_id in by.size():
		var item_on_search 				= by[item_id].begins_with(search_text) || search_text == ""
		var is_item_selected_by_name 	= select_name != "" && by[item_id] == select_name
		var is_item_selected_by_old		= select_name == "" && by[item_id] == old_select
		
		if item_on_search || is_item_selected_by_name || is_item_selected_by_old:
			list.add_item(by[item_id])
			
			if is_item_selected_by_name:
				list.select(list.get_item_count() - 1)
				list.emit_signal("item_selected", list.get_item_count() - 1)
			elif is_item_selected_by_old:
				list.select(list.get_item_count() - 1)
		
	if !list.is_anything_selected() && list.get_item_count() > 0:
		list.select(0)
		list.emit_signal("item_selected", 0)
		
	list.sort_items_by_text()


func set_block_on_edit_buttons(on : bool) -> void:
	rename_bt.disabled = on
	delete_bt.disabled = on


func set_buttons_suffixes(suffix : String) -> void:
	button_suffix = suffix
	
	if !(is_instance_valid(add_bt) && is_instance_valid(rename_bt) && is_instance_valid(delete_bt)):
		return
	
	_on_AddBt_ready()
	_on_RenameBt_ready()
	_on_DeleteBt_ready()


func _on_AddBt_pressed() -> void:
	emit_signal("add_item_request")
	

func _on_RenameBt_pressed() -> void:
	if list.is_anything_selected():
		emit_signal("rename_item_request", get_selected_item())


func _on_DeleteBt_pressed() -> void:
	if list.is_anything_selected():
		emit_signal("delete_item_request", get_selected_item())


func _on_Items_item_selected(index : int) -> void:
	set_block_on_edit_buttons(list.get_item_text(index) in blocked_items)
	emit_signal("item_selected", list.get_item_text(index))


func _on_Search_search_entered(search_text : String) -> void:
	update_list(items)


func _on_AddBt_ready():
	if !is_inside_tree(): yield(self, "ready")
	$All/AddBt.set_deferred("text", "Add " + button_suffix + "...")


func _on_RenameBt_ready():
	if !is_inside_tree(): yield(self, "ready")
	$All/RenameBt.set_deferred("text", "Rename " + button_suffix + "...")


func _on_DeleteBt_ready():
	if !is_inside_tree(): yield(self, "ready")
	$All/DeleteBt.set_deferred("text", "Delete " + button_suffix + "...")
