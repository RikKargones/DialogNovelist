extends Button

onready var popup_menu 		= $PopupPanel
onready var items_scroller 	= $PopupPanel/ScrollContainer
onready var items			= $PopupPanel/ScrollContainer/ItemList

export var rename_button_on_select = true

var banned_items : PoolStringArray

var popup_visible 	= false
var placeholder		= ""

signal list_updated
signal item_selected(item_name)
signal item_index_selected(item_index)


func disconect_from_unicdict() -> void:
	EditLibraly.disconect_incoming_signals(["key_aded", "key_deleted", "key_renamed", "cleared"], self)


func connect_to_unicdict(unic_dict : DialogDispetcher.UnicDict) -> void:
	disconect_from_unicdict()
	
	unic_dict.connect("key_aded", self, "on_dict_add", [unic_dict])
	unic_dict.connect("key_deleted", self, "on_dict_delete", [unic_dict])
	unic_dict.connect("key_renamed", self, "on_dict_rename", [unic_dict])
	unic_dict.connect("cleared", self, "on_dict_clear", [unic_dict])
	
	update_items(unic_dict.keys())


func on_dict_add(_key : String, unic_dict : DialogDispetcher.UnicDict) -> void:
	update_items(unic_dict.keys())


func on_dict_delete(key : String, unic_dict : DialogDispetcher.UnicDict) -> void:	
	if unic_dict.keys().size() != 0 && key == items.get_item_text(get_selected_item()):
		if items.is_anything_selected():
			var index = items.get_selected_items()[0]
			if index != 0: index -= 1
			update_items(unic_dict.keys(), items.get_item_text(index))
			return
	
	update_items(unic_dict.keys())


func on_dict_rename(old_key : String, new_key : String, unic_dict : DialogDispetcher.UnicDict) -> void:
	if old_key == items.get_item_text(get_selected_item()):
		update_items(unic_dict.keys(), new_key)
		return
	
	update_items(unic_dict.keys())


func on_dict_clear(unic_dict : DialogDispetcher.UnicDict) -> void:
	update_items(unic_dict.keys())

	
func _physics_process(delta):
	if get_font("font") != items.get_font("font"):
		items.remove_font_override("font")
		items.add_font_override("font", get_font("font"))
		update_items_size()


func set_banned_items(new_list : PoolStringArray) -> void:
	banned_items = new_list


func get_items_list() -> PoolStringArray:
	var item_list = PoolStringArray([])
	
	for item in items.get_item_count():
		item_list.append(items.get_item_text(item))
		
	return item_list


func get_selected_item() -> int:
	if !items.is_anything_selected(): return -1
	
	return items.get_selected_items()[0]


func get_selected_item_text() -> String:
	var item_index = get_selected_item()
	
	if item_index == -1: return ""
	return items.get_item_text(item_index)


func set_placeholder(new_placeholder : String) -> void:
	if placeholder == new_placeholder: return
	
	var items_list = get_items_list()
	
	if placeholder == "": items_list.insert(0, new_placeholder)
	else: items_list.remove(0)
	
	placeholder = new_placeholder
	
	update_items(items_list)


func update_items(items_list : PoolStringArray, select_item = ""):
	if items_list == get_items_list(): return
	
	var old_item = ""
	
	if items.is_anything_selected(): old_item = items.get_item_text(items.get_selected_items()[0])
	
	var should_seek_old = (select_item.strip_edges() == "" && old_item.strip_edges() != "")
	var should_seek_new = (select_item.strip_edges() != "")
	
	items.clear()
	
	if placeholder.strip_edges() != "":
		items.add_item(placeholder)
	
	for item_id in items_list.size():
		if items_list[item_id] in banned_items || items_list[item_id] == placeholder: continue
		
		items.add_item(items_list[item_id])
		
		var item_text 	= items_list[item_id]
		var aded_id		= items.get_item_count() - 1
		
		if (should_seek_old && old_item == item_text) || (should_seek_new && select_item == item_text):
			items.select(aded_id)
			if should_seek_new:
				emit_signal("list_updated")
				on_item_selection(aded_id)
			text = item_text
	
	if !items.is_anything_selected() && items.get_item_count() > 0:
		items.select(0)
		emit_signal("list_updated")
		on_item_selection(0)
	
	update_items_size()
	
		
func update_items_size():
	items_scroller.scroll_vertical_enabled = items.get_item_count() > 10
	popup_menu.rect_min_size.y = get_font("font").get_height() * 2 * min(items.get_item_count(), 10) + 1
	popup_menu.rect_size.y = popup_menu.rect_min_size.y


func select_item(item_name : String, silent = false) -> void:
	for item_id in items.get_item_count():
		if items.get_item_text(item_id) == item_name:
			items.unselect_all()
			items.select(item_id)
			on_item_selection(item_id, silent)
			break


func select_item_by_index(item_index : int, silent = false) -> void:
	if items.get_item_count() <= item_index || item_index < 0: return
	
	items.unselect_all()
	items.select(item_index)
	on_item_selection(item_index, silent)


func popup_items():
	popup_visible = !popup_visible
	
	if !popup_visible: return
	
	popup_menu.rect_min_size.x = rect_size.x
	update_items_size()
	popup_menu.set_as_minsize()
	
	var fin_pos : Vector2 = rect_global_position
	fin_pos.y += rect_size.y
	
	fin_pos.x = clamp(fin_pos.x, 0, OS.window_size.x - rect_size.x)
	
	if fin_pos.y + popup_menu.rect_size.y > OS.window_size.y:
		fin_pos.y = rect_global_position.y - popup_menu.rect_min_size.y
		
	popup_menu.rect_global_position = fin_pos
	
	popup_menu.popup()

func on_item_selection(index : int, silent = false):
	if !silent:
		emit_signal("item_selected", items.get_item_text(index))
		emit_signal("item_index_selected", index)
	
	if rename_button_on_select: text = items.get_item_text(index)
	popup_menu.hide()
	popup_visible = false


func _on_ScrollablePopupMenu_pressed():
	popup_items()


func _on_ItemList_item_selected(index : int):
	on_item_selection(index)


func _on_PopupPanel_popup_hide():
	popup_visible = false
