extends HBoxContainer

onready var splitter 					= $Split
onready var dialog_list					= $DialogList
onready var add_setting_selector		= $Split/NodeEdit/NodeInfoShower/Settings/AddBlockBt

onready var node_edit_ui				= $Split/NodeEdit
onready var node_edit_handler 			= $Split/NodeEdit/NodeInfoShower/Settings/Scroll/DialogNodeSettingsHandler

onready var map							= $Split/MapUi/Map
onready var add_menu					= $Split/MapUi/Map/AddMenu
onready var templates_menu				= $Split/MapUi/Map/AddMenu/TemplatesMenu
onready var blocker						= $Split/MapUi/Blocker

onready var is_start_bt					= $Split/NodeEdit/NodeInfoShower/Settings/Start/IsStart
onready var start_point_name			= $Split/NodeEdit/NodeInfoShower/Settings/Start/PointName


var node_ui_paths 		: UnicDict 		= UnicDict.new()
var node_ui_templates 	: UnicDict 		= UnicDict.new()
var edit_node 			: DialogNodeUi
var confict_list 		: Dictionary

const add_empty_key = "Add Empty Node"


func load_paths() -> void:
	var dir = Directory.new()
	
	node_ui_paths.clear()
	
	var ui_paths_folder = "res://EditorsElements/DialogEditor/BlockUiPathInfo/"
	
	if dir.open(ui_paths_folder) != OK:
		Ui.popup_error("Can't open folder with paths to ui scenes!", "DIALOG_EDITOR - LOADING UI PATHS")
		return
		
	dir.list_dir_begin(true)
	var cur_file = dir.get_next()
	
	while cur_file != "":
		if !dir.current_is_dir():
			var res = load(ui_paths_folder + cur_file)
			if res is DialogEditorUiPathBase:
				if EditLibraly.is_dialog_editor_ui_path_valid(res, "DIALOG_EDITOR - LOADING UI PATHS (" + cur_file + ")"):
					var edit_inst : BlockInfoEditUi 	= res.edit_ui_scene.instance()
					var show_inst : BlockInfoGraphUi 	= res.graph_node_ui_scene.instance()
					
					node_ui_paths.add_key(cur_file.trim_suffix(".tres"), res)
	
					if res.conflict_blocks.size() > 0:
						confict_list[res.base_key] = res.conflict_blocks
				
		cur_file = dir.get_next()
		

func load_templates() -> void:
	var dir = Directory.new()
	
	node_ui_templates.clear()
	
	var templates_folder = "res://DialogEditorNodeTemplates/"
	
	if dir.open(templates_folder) != OK:
		Ui.popup_error("Can't open folder with node templates!", "DIALOG_EDITOR - LOADING")
		return
		
	dir.list_dir_begin(true)
	var cur_file = dir.get_next()
	
	while cur_file != "":
		if !dir.current_is_dir():
			var res = load(templates_folder + cur_file)
			if res is DialogNodeTemplate:
				if res.block_list.size() == 0: continue
				
				node_ui_templates.add_key(cur_file.trim_suffix(".tres"), res)
				templates_menu.add_item(cur_file.trim_suffix(".tres"))
				
		cur_file = dir.get_next()
				

func _ready() -> void:
	load_paths()
	load_templates()
	
	blocker.visible = true
	
	dialog_list.connect_to_unicdict(DialogsData.dialogs)
	add_setting_selector.connect_to_unicdict(node_ui_paths)
	node_edit_ui.visible = false
	
	add_menu.add_item(add_empty_key)
	
	add_menu.add_item("Templates")
	add_menu.set_item_submenu(1, templates_menu.name)
	add_menu.set_item_disabled(1, templates_menu.items.size() == 0)


func get_current_dialoginfo() -> EditorDialogInfo:
	blocker.visible = DialogsData.dialogs.keys().size() == 0
	
	return DialogsData.get_dialog(dialog_list.get_selected_item())


func update_add_block_conflicts() -> void:
	if !is_instance_valid(edit_node): return
	
	var nodeinfo = edit_node.nodeinfo_path.get_node_info()
	
	if !is_instance_valid(nodeinfo):
		add_setting_selector.set_banned_items([])
		return
	
	var ban_list = []
	
	for block_name in nodeinfo.get_blocks_list():
		for conflict in confict_list.keys():
			if block_name.begins_with(conflict):
				ban_list.append_array(confict_list[conflict])
				break
	
	add_setting_selector.disconnect("item_selected", self, "_on_AddSettingBt_item_selected")
	add_setting_selector.set_banned_items(ban_list)
	add_setting_selector.connect("item_selected", self, "_on_AddSettingBt_item_selected")


func set_edit_node(node : DialogNodeUi) -> void:
	if node == edit_node: return
	
	var dialogdata = get_current_dialoginfo()
	
	if is_instance_valid(edit_node):
		edit_node.self_modulate = Color.white
		edit_node = null
	
	node_edit_ui.visible = is_instance_valid(node) && is_instance_valid(dialogdata)
	
	if !node_edit_ui.visible:
		node_edit_handler.clear_handler()
		return
	
	node_edit_handler.connect_to_nodeinfo(node.nodeinfo_path)
	node.self_modulate = Color.orange
	if !node.is_selected(): node.selected = true
	
	is_start_bt.pressed = dialogdata.is_start_node(node.name)
	start_point_name.disabled = !is_start_bt.pressed
	
	if is_start_bt.pressed:
		start_point_name.text = dialogdata.get_start_node_name(node.name)
	else:
		start_point_name.text = ""
	
	edit_node = node
		
	update_add_block_conflicts()


func add_new_node(offset : Vector2, template : DialogNodeTemplate = null) -> DialogNodeUi:
	var dialogdata = get_current_dialoginfo()
	
	if !is_instance_valid(dialogdata): return null
	
	var node_ui = add_node_ui()
	var new_nodeinfo
	
	if is_instance_valid(template):
		new_nodeinfo = template.generate_nodeinfo(dialogdata, node_ui.name)
	else:
		new_nodeinfo = dialogdata.add_node(node_ui.name)
	
	if new_nodeinfo is EditorNodeInfo:
		new_nodeinfo.offset = offset
		node_ui.bound_to_nodeinfo(NodeInfoPath.new(dialog_list.get_selected_item(), node_ui.name))
	elif is_instance_valid(new_nodeinfo):
		node_ui.queue_free()
		
	return node_ui


func load_node(node_name : String) -> void:
	var dialogdata = get_current_dialoginfo()
	
	if !is_instance_valid(dialogdata): return
	
	var nodeinfo = dialogdata.get_node(node_name)
	
	if !is_instance_valid(nodeinfo): return
	
	if nodeinfo is EditorNodeInfo:
		var node_ui = add_node_ui()
		node_ui.name = node_name
		node_ui.bound_to_nodeinfo(NodeInfoPath.new(dialog_list.get_selected_item(), node_ui.name))


func add_node_ui() -> DialogNodeUi:
	var node_ui = DialogNodeUi.new()
	map.add_child(node_ui, true)
	node_ui.connect("close_request", self, "delete_node", [node_ui])
	node_ui.connect("need_disconect", self, "erase_port_connections", [node_ui])
	return node_ui


func delete_node(node : DialogNodeUi) -> void:
	var dialoginfo = get_current_dialoginfo()
	
	if !is_instance_valid(dialoginfo) || !is_instance_valid(node): return
	
	for con in map.get_connection_list():
		if con["from"] == node.name || con["to"] == node.name:
			map.disconnect_node(con["from"], con["from_port"], con["to"], con["to_port"])
			dialoginfo.disconnect_nodes(con["from"], con["to"], con["from_port"])
			
	dialoginfo.erase_node(node.name)
	node.queue_free()


func disconnect_node(from : String, to : String, port : int) -> void:
	var dialoginfo = get_current_dialoginfo()
	
	if !is_instance_valid(dialoginfo): return
	
	map.disconnect_node(from, port, to, 0)
	dialoginfo.disconnect_nodes(from, to, port)


func erase_port_connections(index : int, node : DialogNodeUi) -> void:
	var dialoginfo = get_current_dialoginfo()
	
	if !is_instance_valid(dialoginfo) || !is_instance_valid(node): return
	
	for con in dialoginfo.get_next_nodes(node.name):
		if con["slot"] == index:
			disconnect_node(node.name, con["node"], index)


func clear_map() -> void:
	map.clear_connections()
	
	set_edit_node(null)
	
	for child in map.get_children():
		if child is GraphNode:
			child.queue_free()


func load_current_dialog() -> void:
	clear_map()
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	var diainfo = get_current_dialoginfo()
	
	if !is_instance_valid(diainfo): return
	
	for node in diainfo.get_nodes_list():
		load_node(node)
		
	for con in diainfo.get_node_connections():
		map.connect_node(con["from_node"], con["from_slot"], con["to_node"], 0)	
	

func _on_DialogList_add_item_request() -> void:
	var connect_info = Ui.ConnectInfo.new(DialogsData, "add_dialog")
	Ui.popup_namer(connect_info, "Name new dialog...", DialogsData.dialogs.keys(), "Dialog name:", true)


func _on_HideButton_hide_hidable_node() -> void:
	splitter.split_offset = 0


func _on_Map_popup_request(position : Vector2) -> void:
	add_menu.rect_position = get_global_mouse_position()
	add_menu.popup()


func _on_Map_node_selected(node : DialogNodeUi) -> void:
	set_edit_node(node)


func _on_Map_node_unselected(node : DialogNodeUi) -> void:
	if edit_node == node: set_edit_node(null)


func _on_AddSettingBt_item_selected(item_name : String) -> void:
	if !is_instance_valid(edit_node): return
	
	var nodeinfo : EditorNodeInfo 			= edit_node.nodeinfo_path.get_node_info()
	var ui_paths : DialogEditorUiPathBase 	= node_ui_paths.get_value(item_name)
	
	if !is_instance_valid(nodeinfo) || !EditLibraly.is_dialog_editor_ui_path_valid(ui_paths, "DIALOG_EDITOR - On block add"): return
	
	nodeinfo.add_block(ui_paths)
	
	update_add_block_conflicts()


func _on_AddMenu_index_pressed(index : int) -> void:
	if add_menu.get_item_text(index) != add_empty_key: return
	
	set_edit_node(add_new_node(add_menu.rect_position - map.rect_global_position + map.scroll_offset))


func _on_Map_connection_request(from : String, from_slot : int, to : String, to_slot : int) -> void:
	if from == to: return
	
	var dialoginfo = get_current_dialoginfo()
	
	if !is_instance_valid(dialoginfo): return
	
	erase_port_connections(from_slot, map.get_node(from))
			
	dialoginfo.connect_nodes(from, to, from_slot)
	map.connect_node(from, from_slot, to, 0)


func _on_Map_connection_from_empty(to, to_slot, release_position) -> void:
	var dialoginfo = get_current_dialoginfo()
	
	if !is_instance_valid(dialoginfo): return
	
	for con in dialoginfo.get_prev_nodes(to):
		disconnect_node(map.get_node(con["node"]), to, con["slot"])
	
	
func _on_Map_connection_to_empty(from, from_slot, release_position) -> void:
	var dialoginfo = get_current_dialoginfo()
	
	if !is_instance_valid(dialoginfo): return
	
	erase_port_connections(from_slot, map.get_node(from))


func _on_Map_disconnection_request(from, from_slot, to, to_slot) -> void:
	var dialoginfo = get_current_dialoginfo()
	
	if !is_instance_valid(dialoginfo): return
	
	disconnect_node(from, to, from_slot)
	
	
func _on_Map_delete_nodes_request(nodes : Array) -> void:
	for node in nodes:
		delete_node(map.get_node(node))


func _on_DialogList_delete_item_request(item_name : String) -> void:
	var connect_info = Ui.ConnectInfo.new(DialogsData, "remove_dialog", [item_name])
	Ui.popup_confirm(connect_info, "Are you sure to delete whole dialog?")
	

func _on_DialogList_item_selected(_item_name : String) -> void:
	load_current_dialog()


func _on_DialogList_rename_item_request(item_name : String) -> void:
	var connect_info = Ui.ConnectInfo.new(DialogsData, "rename_dialog", [item_name])
	Ui.popup_namer(connect_info, "Rename dialog...", DialogsData.dialogs.keys(), "New dialog name:", true)


func _on_IsStart_toggled(button_pressed : bool) -> void:
	var dialoginfo = get_current_dialoginfo()
	
	if !is_instance_valid(dialoginfo) || !is_instance_valid(edit_node):
		return
	
	start_point_name.disabled = !button_pressed
	
	if button_pressed:
		var defname = edit_node.nodeinfo_path.dialog + "_StartPoint"
		dialoginfo.add_start_node(edit_node.name, FilesData.make_string_nambered(defname, dialoginfo.get_start_nodes_names()))
		start_point_name.text = dialoginfo.get_start_node_name(edit_node.name)
	else:
		dialoginfo.erase_start_node(edit_node.name)


func _on_PointName_pressed() -> void:
	var dialoginfo = get_current_dialoginfo()
	
	if !is_instance_valid(edit_node) || !is_instance_valid(dialoginfo): return
	
	var connectinfo = Ui.ConnectInfo.new(self, "set_start_node_name", [edit_node.name])
	Ui.popup_namer(connectinfo, "Set start node name", dialoginfo.get_start_nodes_names(), "", true)


func set_start_node_name(new_start_node_name : String, node_name : String) -> void:
	var dialoginfo = get_current_dialoginfo()
	
	if !is_instance_valid(dialoginfo): return
	
	dialoginfo.set_start_node_point_name(node_name, new_start_node_name)
	
	if !is_instance_valid(edit_node) || edit_node.name != node_name: return
	
	start_point_name.text = dialoginfo.get_start_node_name(node_name)


func _on_DialogNodeSettingsHandler_child_exiting_tree(node : Node) -> void:
	update_add_block_conflicts()


func _on_TemplatesMenu_index_pressed(index : int) -> void:
	set_edit_node(add_new_node(add_menu.rect_position - map.rect_global_position + map.scroll_offset, node_ui_templates.get_value(templates_menu.get_item_text(index))))
	

func _on_Map_child_exiting_tree(node : DialogNodeUi) -> void:
	if node == edit_node: set_edit_node(null)
