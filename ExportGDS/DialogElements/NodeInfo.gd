extends Resource

class_name NodeInfo

export var blocks : Resource = UnicDict.new()
	
func has_block(key : String) -> bool:
	return blocks.has(key)

func get_blocks_list() -> Array:
	return blocks.keys()

func get_block(key : String) -> NodeBlockInfo:
	return blocks.get_value(key)
