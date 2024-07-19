extends DialogInfo

class_name EditorDialogInfo

func add_node(node_name : String) -> NodeInfo:
	node_list.add_key(node_name, EditorNodeInfo.new())
	return get_node(node_name)


func switch_node_info(node_name : String, node_data : NodeInfo) -> void:
	node_data.set_key(node_name, node_data)


func erase_node(node_name : String) -> void:		
	node_list.erase(node_name)
	start_nodes.erase(node_name)


func add_start_node(node_name : String, point_name : String) -> void:
	if !has_node(node_name) || is_start_node(node_name): return
	
	start_nodes.add_key(node_name, point_name)
	
	
func set_start_node_point_name(node_name : String, new_point_name : String) -> void:
	if !has_node(node_name) || !is_start_node(node_name): return
	
	start_nodes.set_key(node_name, new_point_name)
	

func erase_start_node(node_name : String) -> void:
	start_nodes.erase(node_name)


func connect_nodes(from_node_name : String, to_node_name : String, from_port : int) -> void:
	if !has_node(from_node_name) || !has_node(to_node_name) || is_nodes_connected(from_node_name, to_node_name, from_port): return
	
	var from_node 	= get_node(from_node_name)
	var to_node		= get_node(to_node_name)
	
	if !is_instance_valid(from_node) || !is_instance_valid(to_node): return
	
	node_connections.append({"from_node" : from_node_name, "to_node" : to_node_name, "from_slot" : from_port})
	to_node.emit_signal("connections_updated")
	from_node.emit_signal("connections_updated")
	send_connection_msg(from_node_name, to_node_name, from_port, false)


func disconnect_nodes(from_node_name : String, to_node_name : String, from_port : int) -> void:
	var from_node 	= get_node(from_node_name)
	var to_node		= get_node(to_node_name)
	
	if !is_instance_valid(from_node) || !is_instance_valid(to_node): return
	
	for con in node_connections:
		if con["from_node"] == from_node_name && con["to_node"] == to_node_name && con["from_slot"] == from_port:
			node_connections.erase(con)
			to_node.emit_signal("connections_updated")
			from_node.emit_signal("connections_updated")
			send_connection_msg(from_node_name, to_node_name, from_port, true)
			break


func send_connection_msg(from_node_name : String, to_node_name : String, from_port : int, lost : bool) -> void:
	var lost_msg = ConnectionMsg.new()
	
	lost_msg.from_node = from_node_name
	lost_msg.to_node = to_node_name
	lost_msg.from_slot = from_port
	lost_msg.is_lost = lost
	
	lost_msg.origin = to_node_name
	send_msg_to_back_nodes(lost_msg, from_node_name)
	lost_msg.origin = from_node_name
	send_msg_to_next_nodes(lost_msg, to_node_name)


func send_msg_to_node(msg : NodeInfoMsg, node_name : String) -> void:
	var node = get_node(node_name)
	
	if !is_instance_valid(node): return
	
	node.recive_msg(msg)


func send_msg_to_next_nodes(msg : NodeInfoMsg, passed_from : String = "", passed_list : Array = []) -> void:
	if !is_instance_valid(msg) && !msg.is_should_pass() || passed_list.size() > 200 || !has_node(msg.origin): return
	
	var nodes : Array
	
	if passed_from != "": nodes = get_next_nodes(passed_from)
	else: nodes = get_next_nodes(msg.origin)
	
	for con in nodes:
		var node_name = con["node"]
		
		if passed_list.has(node_name) || msg.origin == node_name: continue
		
		var node = get_node(node_name)
		
		if !is_instance_valid(node): continue
		
		passed_list.append(node_name)
		
		var copy_msg = EditLibraly.duplacate_scripted_object(msg)
		
		node.recive_msg_from_back(copy_msg)
		send_msg_to_next_nodes(copy_msg, node_name, passed_list)
	
	
func send_msg_to_back_nodes(msg : NodeInfoMsg, passed_from : String = "", passed_list : Array = []) -> void:
	if !is_instance_valid(msg) && !msg.is_should_pass() || passed_list.size() > 200 || !has_node(msg.origin): return
	
	var nodes : Array
	
	if passed_from != "": nodes = get_prev_nodes(passed_from)
	else: nodes = get_prev_nodes(msg.origin)
	
	for con in nodes:
		var node_name = con["node"]
		
		if passed_list.has(node_name) || msg.origin == node_name: continue
		
		var node = get_node(node_name)
		
		if !is_instance_valid(node): continue
		
		passed_list.append(node_name)
		
		var copy_msg = EditLibraly.duplacate_scripted_object(msg)
		
		node.recive_msg_from_next(copy_msg)
		send_msg_to_back_nodes(copy_msg, node_name, passed_list)
