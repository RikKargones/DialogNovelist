extends BlockInfoEditUi

onready var varible_pick 		= $Varible/VariblePick
onready var set_tab				= $Set

onready var bool_state			= $Set/Bool/BoolState

onready var string_edit			= $Set/String/StringEdit

onready var number				= $Set/Number/NumberEdit
onready var num_actions			= $Set/Number/NumberActions

var sinhronizing = false

enum TABS_LIST {BOOL = 0, NUMBER = 1, STRING = 2, NONE = 3}

func _ready() -> void:
	for state_idx in NBI_V_Bool.ACTION.keys().size():
		bool_state.add_item(NBI_V_Bool.ACTION.keys()[state_idx].capitalize(), NBI_V_Bool.ACTION.values()[state_idx])
	
	for state_idx in NBI_V_Number.ACTIONS.keys().size():
		num_actions.add_item(NBI_V_Number.ACTIONS.keys()[state_idx].capitalize(), NBI_V_Number.ACTIONS.values()[state_idx])
	
	VariblesData.connect("varible_aded", self, "on_varible_add_delete")
	VariblesData.connect("varible_deleted", self, "on_varible_add_delete")
	VariblesData.connect("varible_renamed", self, "on_varible_rename")
	
	on_varible_add_delete()


func on_varible_add_delete(_var_name : String = "") -> void:
	varible_pick.update_items(VariblesData.get_varibles_list())


func on_varible_rename(old_var_name : String, new_var_name : String) -> void:
	if varible_pick.get_selected_item_text() == old_var_name:
		varible_pick.update_items(VariblesData.get_varibles_list(), new_var_name)
	else:
		varible_pick.update_items(VariblesData.get_varibles_list())


func _update_ui() -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_Varible:
		varible_pick.select_item(blockinfo.varible_name)
		_on_VariblePick_item_selected(varible_pick.text)
		blockinfo = get_blockinfo_copy()
		
		if blockinfo is NBI_V_Bool:
			set_tab.current_tab = TABS_LIST.BOOL
			bool_state.select(blockinfo.action)
			return
			
		if blockinfo is NBI_V_Number:
			set_tab.current_tab = TABS_LIST.NUMBER
			
			number.set_number(blockinfo.value)
			return
		
		if blockinfo is NBI_V_String:
			set_tab.current_tab = TABS_LIST.STRING
			string_edit.set_text(blockinfo.value)
			return
	
	set_tab.current_tab = TABS_LIST.NONE


func _get_blockinfo_script() -> GDScript:
	return NBI_Varible


func save() -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_Varible:
		var has_varible = VariblesData.has_varible(varible_pick.get_selected_item_text())
		
		if has_varible:
			blockinfo.varible_name = varible_pick.get_selected_item_text()
		else:
			var replace_info = NBI_Varible.new()
			replace_block_data(replace_info)
			save_changes(replace_info)
			return
		
		if blockinfo is NBI_V_Bool:
			blockinfo.action 	= bool_state.get_selected_id()
				
		if blockinfo is NBI_V_Number:
			blockinfo.action 	= num_actions.get_selected_id()
			blockinfo.value		= number.get_number()
			
		if blockinfo is NBI_V_String:
			blockinfo.value		= string_edit.get_text()
		
		save_changes(blockinfo)


func _on_NumberActions_item_selected(_index : int) -> void:	
	if get_blockinfo_copy() is NBI_V_Number:
		save()


func _on_BoolState_item_selected(_index : int) -> void:
	if get_blockinfo_copy() is NBI_V_Bool:
		save()


func _on_VariblePick_item_selected(item_name : String) -> void:
	var blockinfo_new : NBI_Varible
	
	if VariblesData.get_number_list().has(item_name):
		blockinfo_new = NBI_V_Number.new()
		set_tab.current_tab = TABS_LIST.NUMBER
	elif VariblesData.get_string_list().has(item_name):
		blockinfo_new = NBI_V_String.new()
		set_tab.current_tab = TABS_LIST.STRING
	elif VariblesData.get_bool_list().has(item_name):
		blockinfo_new = NBI_V_Bool.new()
		set_tab.current_tab = TABS_LIST.BOOL
	else:
		set_tab.current_tab = TABS_LIST.NONE
		return
	
	blockinfo_new.varible_name = item_name
	replace_block_data(blockinfo_new)
	save()
	
	
func _on_NumberEdit_number_changed(_num : float) -> void:
	if get_blockinfo_copy() is NBI_V_Number:
		save()


func _on_StringEdit_text_changed(_new_text : String) -> void:
	if get_blockinfo_copy() is NBI_V_String:
		save()
