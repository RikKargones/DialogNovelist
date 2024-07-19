extends Resource

class_name DialogInfo

export var node_list		: Resource = UnicDict.new()
export var start_nodes		: Resource = UnicDict.new()
export var node_connections	: Array # {from_node, to_node, from_slot}

func has_node(node_name : String) -> bool:
	return node_name in node_list.keys()

func has_start_point(point_name : String) -> bool:
	return get_start_nodes_names().has(point_name)
	
func get_node(node_name : String) -> NodeInfo:
	return node_list.get_value(node_name)

func get_start_nodes_list() -> Array:
	return start_nodes.keys()

func get_start_nodes_names() -> Array:
	return start_nodes.values()

func get_start_node_name(node_name : String) -> String:
	if start_nodes.has(node_name):
		return start_nodes.get_value(node_name)
	return ""

func get_nodes_list() -> Array:
	return node_list.keys()

func get_node_connections() -> Array:
	return node_connections.duplicate(true)	
	
func get_next_nodes(node_name : String) -> Array:
	var nodes = []
	
	for con in node_connections:
		if con["from_node"] == node_name:
			nodes.append({"node" : con["to_node"], "slot" : con["from_slot"]})
			
	return nodes
	
func get_prev_nodes(node_name : String) -> Array:
	var nodes = []
	
	for con in node_connections:
		if con["to_node"] == node_name:
			nodes.append({"node" : con["from_node"], "slot" : con["from_slot"]})
			
	return nodes

func is_start_node(node : String) -> bool:
	return start_nodes.has(node)

func is_nodes_connected(from_node_name : String, to_node_name : String, from_port : int) -> bool:
	if !has_node(from_node_name) || !has_node(to_node_name): return false
	
	for con in node_connections:
		if con["from_node"] == from_node_name && con["to_node"] == to_node_name && con["from_slot"] == from_port:
			return true	
	
	return false
	
func _to_string() -> String:
	return "{Nodes: " + str(node_list) +", Connections: " + str(node_connections) + ", StartNodes: " + str(start_nodes) + "}"
