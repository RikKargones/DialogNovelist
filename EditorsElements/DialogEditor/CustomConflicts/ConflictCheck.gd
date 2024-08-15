tool
extends Resource

class_name ConflictCheck

export (Array, Resource) var conflict_pck : Array

func is_conflicting(nodeinfo_pcks : Array) -> bool:		
	return is_pck_not_right(nodeinfo_pcks) || _custom_check(nodeinfo_pcks)
	
	
func is_pck_not_right(_nodeinfo_pcks : Array) -> bool:
	for pck in _nodeinfo_pcks:
		if conflict_pck.has(pck): return true
	
	return false
	
	
func _custom_check(_nodeinfo_pcks : Array) -> bool:
	return false
