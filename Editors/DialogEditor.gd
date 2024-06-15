extends HBoxContainer

onready var splitter 				= $Split
onready var map						= $Split/Map
onready var dialog_list				= $DialogList
onready var node_edit_handler 		= $Split/NodeEdit/NodeInfoShower/Settings/Scroll/DialogNodeSettingsHandler
onready var edit_node_ui			= $Split/NodeEdit
onready var add_setting_selector	= $Split/NodeEdit/NodeInfoShower/Settings/AddSettingBt

onready var add_menu				= $Control/AddMenu
onready var templates_menu			= $Control/AddMenu/TemplatesMenu

var node_ui_paths 	: DialogDispetcher.UnicDict = DialogDispetcher.UnicDict.new()
var edit_node 		: DialogNodeUi

const add_empty_key = "Add Empty Node"

func load_paths() -> void:
	var dir = Directory.new()
	
	node_ui_paths.clear()
	
	var ui_paths_folder = "res://UI/EditorsElements/DialogEditor/BlockUiPathInfo/"
	
	if dir.open(ui_paths_folder) != OK:
		Ui.popup_error("Can't open folder with paths to ui scenes!", "DIALOG_EDITOR - LOADING")
		return
		
	dir.list_dir_begin(true)
	var cur_file = dir.get_next()
	
	while cur_file != "":
		if !dir.current_is_dir():
			var res = load(ui_paths_folder + cur_file)
			if res is DialogEditorUiPathBase:
				if EditLibraly.is_dialog_editor_ui_path_valid(res, "DIALOG_EDITOR - LOADING(" + cur_file + ")"):
					var edit_inst : BlockInfoEditUi 	= res.edit_ui_scene.instance()
					var show_inst : BlockInfoGraphUi 	= res.graph_node_ui_scene.instance()
					
					node_ui_paths.add_key(cur_file.trim_suffix(".tres"), res)
				
		cur_file = dir.get_next()
		

func prepare_to_test() -> void:
	DialogsData.add_dialog("TestDia")


func _ready() -> void:
	load_paths()
	prepare_to_test()
	dialog_list.connect_to_unicdict(DialogsData.dialogs)
	add_setting_selector.connect_to_unicdict(node_ui_paths)
	edit_node_ui.visible = false
	
	add_menu.add_item("Templates")
	add_menu.add_item(add_empty_key)
	add_menu.set_item_submenu(0, templates_menu.name)
	add_menu.set_item_disabled(0, true)


func get_current_dialoginfo() -> EditorDialogData:
	return DialogsData.get_dialog(dialog_list.get_selected_item())


func set_edit_node(node : DialogNodeUi) -> void:
	if node == edit_node: return
	
	if is_instance_valid(edit_node):
		edit_node.self_modulate = Color.white
		edit_node = null
	
	if is_instance_valid(node) && is_instance_valid(get_current_dialoginfo()):
		edit_node_ui.visible = true
		node_edit_handler.connect_to_nodeinfo(node.nodeinfo_path)
		node.self_modulate = Color.orange
	else:
		edit_node_ui.visible = false
	
	edit_node = node


func add_node(offset : Vector2) -> void:
	var dialogdata = get_current_dialoginfo()
	
	if is_instance_valid(dialogdata):
		var node_ui = DialogNodeUi.new()
		map.add_child(node_ui, true)
		dialogdata.add_node(node_ui.name)
		node_ui.offset = offset
		node_ui.bound_to_nodeinfo(NodeInfoPath.new(dialog_list.get_selected_item(), node_ui.name))


func _on_DialogList_add_item_request() -> void:
	var name_popup = NameDialog.new("Name new dialog...", DialogsData.dialogs.keys(), "Dialog name:", true)
	Ui.add_popup(name_popup, "name_confurmed", self, "dialog_add_confurmed")


func dialog_add_confurmed(new_dialog_name : String) -> void:
	DialogsData.add_dialog(new_dialog_name)


func _on_HideButton_hide_hidable_node() -> void:
	splitter.split_offset = 0


func _on_Map_popup_request(position : Vector2) -> void:
	test_add()
	
	
func test_add() -> void:
	add_node(map.get_local_mouse_position() + map.scroll_offset)


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


func _on_AddMenu_index_pressed(index : int) -> void:
	if add_menu.get_item_text(index) != add_empty_key: return
	
	add_node(map.get_local_mouse_position() + map.scroll_offset)


func _on_Map_connection_request(from : String, from_slot : int, to : String, to_slot : int) -> void:
	if from == to: return
	
	var dialoginfo = get_current_dialoginfo()
	
	if !is_instance_valid(dialoginfo): return
	
	for con in dialoginfo.get_next_nodes(from):
		if dialoginfo.is_nodes_connected(from, con["node"], from_slot):
			dialoginfo.disconnect_nodes(from, con["node"], from_slot)
			
	for con in map.get_connection_list():
		if con["from"] == from && con["from_port"] == from_slot:
			map.disconnect_node(from, from_slot, con["to"], 0)
			
	dialoginfo.connect_nodes(from, to, from_slot)
	map.connect_node(from, from_slot, to, 0)


func _on_Map_connection_from_empty(to, to_slot, release_position):
	var dialoginfo = get_current_dialoginfo()
	
	if !is_instance_valid(dialoginfo): return
	
	for con in dialoginfo.get_prev_nodes(to):
		dialoginfo.disconnect_nodes(con["node"], to, con["slot"])
	
	for con in map.get_connection_list():
		if con["to"] == to:
			map.disconnect_node(con["from"], con["from_port"], to, 0)
	
	
func _on_Map_connection_to_empty(from, from_slot, release_position):
	var dialoginfo = get_current_dialoginfo()
	
	if !is_instance_valid(dialoginfo): return
	
	for con in dialoginfo.get_next_nodes(from):
		if con["slot"] == from_slot:
			dialoginfo.disconnect_nodes(from, con["node"], from_slot)
			
	for con in map.get_connection_list():
		if con["from"] == from && con["from_port"] == from_slot:
			map.disconnect_node(from, from_slot, con["to"], 0)


func _on_Map_disconnection_request(from, from_slot, to, to_slot):
	var dialoginfo = get_current_dialoginfo()
	
	if !is_instance_valid(dialoginfo): return
	
	map.disconnect_node(from, from_slot, to, 0)
	dialoginfo.disconnect_nodes(from, to, from_slot)
	
	
