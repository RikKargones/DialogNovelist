tool
extends Resource

class_name DialogEditorUiPathBase

enum OrderFlag {NONE, ALWAYS_FIRST, ALWAYS_LAST}

export (String)			var base_key			: String
export (PackedScene) 	var edit_ui_scene		: PackedScene
export (PackedScene) 	var graph_node_ui_scene	: PackedScene
export (OrderFlag)		var order_flag			: int
export (Resource)		var conflicts			: Resource		= ConflictCheck.new() setget on_conflictcheck_set


func on_conflictcheck_set(new_conflictcheck : ConflictCheck) -> void:
	if !is_instance_valid(new_conflictcheck): conflicts = ConflictCheck.new()
	else: conflicts = new_conflictcheck

