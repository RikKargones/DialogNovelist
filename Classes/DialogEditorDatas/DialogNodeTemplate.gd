tool
extends Resource

class_name DialogNodeTemplate

export (Array, Resource) 	var block_list			: Array			setget on_block_list_set
export (Dictionary) 		var sinhronization_list	: Dictionary 	setget on_sinhronization_list_set


func on_block_list_set(new_block_list : Array) -> void:
	var final_dict : Array
	
	for block_id in new_block_list.size():
		var block : DialogEditorUiPathBase = new_block_list[block_id]
		
		if is_instance_valid(block):
			var has_conflict : bool = false
			
			for other_block in final_dict:
				var other_ui_path : DialogEditorUiPathBase = other_block
				var ui_path_name : String = block.resource_path.trim_suffix(".tres").rsplit("/", false, 1)[1] 
				
				if other_ui_path.conflict_blocks.has(ui_path_name):
					has_conflict = true
					break
								
			if has_conflict: continue
		elif block_id != new_block_list.size() - 1:
			continue
			
		final_dict.append(block)
	
	block_list = final_dict
	
	on_sinhronization_list_set(sinhronization_list)
	property_list_changed_notify()
	
	
func on_sinhronization_list_set(new_sinhro_list : Dictionary) -> void:
	var final_arr : Dictionary
	
	for sinhronize_item in new_sinhro_list.keys():
		var same_id 		: bool = sinhronize_item == new_sinhro_list[sinhronize_item]
		var first_valid 	: bool = sinhronize_item is int && sinhronize_item >= 0 && sinhronize_item < block_list.size()
		var second_valid 	: bool = new_sinhro_list[sinhronize_item] is int && new_sinhro_list[sinhronize_item] >= 0 && new_sinhro_list[sinhronize_item] < block_list.size()
		
		if same_id || !first_valid || !second_valid: continue
		
		final_arr[sinhronize_item] = new_sinhro_list[sinhronize_item]
	
	sinhronization_list = final_arr
	

func generate_nodeinfo(dialog : EditorDialogInfo, node_name : String) -> EditorNodeInfo:	
	if !is_instance_valid(dialog): return null
	
	var new_node : EditorNodeInfo = dialog.add_node(node_name)
	
	if !is_instance_valid(new_node): return null
	
	var blocks_names : Array
	
	for block in block_list:
		blocks_names.append(new_node.add_block(block, null))
		
	for sinhronize in sinhronization_list.keys():
		new_node.connect_sinhronize_keys(blocks_names[sinhronize], blocks_names[sinhronization_list[sinhronize]])
	
	return new_node
