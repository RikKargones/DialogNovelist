tool
extends Resource

class_name DialogEditorUiPathBase

enum OrderFlag {NONE, ALWAYS_FIRST, ALWAYS_LAST}

export (String)				var base_key			: String
export (PackedScene) 		var edit_ui_scene		: PackedScene
export (PackedScene) 		var graph_node_ui_scene	: PackedScene
export (OrderFlag)			var order_flag			: int
export (PoolStringArray)	var conflict_blocks		: PoolStringArray

