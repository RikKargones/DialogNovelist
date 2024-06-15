extends Resource

class_name NodeInfoMsg
	
export var respond_list 	: PoolStringArray 	= []
export var pass_next 		: bool 				= true
export var origin 			: String

	
func disable_pass() -> void:
	pass_next = false
	
	
func is_should_pass() -> bool:
	return pass_next
	
	
func add_respond(respond_name : String) -> void:
	if respond_list.has(respond_name): return
	respond_list.append(respond_name)
