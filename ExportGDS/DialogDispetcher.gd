extends Node

enum FONT_NAMES		{}
enum VARIBLE_NAMES 	{}
enum SIGNAL_NAMES	{}
enum PERSON_IDS		{}
enum DIALOG_NAMES 	{}

var path_to_data 		: String

var fonts_data 			: Dictionary
var varibles_int_data 	: Dictionary
var varibles_bool_data	: Dictionary
var varibles_str_data	: Dictionary
var person_data 		: Dictionary
var dialogs_data 		: Dictionary

#CUSTOM_SIGNALS

class UnicDict extends Resource:
	export var dict : Dictionary
	
	signal key_aded(key)
	signal key_renamed(old_key, new_key)
	signal key_deleted(key)
	signal cleared()
	
	func keys() -> Array:
		return dict.keys()
		
	func get_value(key : String):
		if !dict.has(key): return null
		return dict[key]
		
	func has(key : String) -> bool:
		return dict.has(key)		
	
	func add_key(key : String, value) -> void:
		if dict.has(key): return
		dict[key] = value
		emit_signal("key_aded", key)
		
	func set_key(key : String, value) -> void:
		if !dict.has(key): return
		dict[key] = value
		
	func rename_key(old_key : String, new_key : String) -> void:
		if !dict.has(old_key) || dict.has(new_key): return
		dict[new_key] = dict[old_key]
		dict.erase(old_key)
		emit_signal("key_renamed", old_key, new_key)
	
	func clear() -> void:
		dict.clear()
		emit_signal("cleared")
	
	func erase(key : String) -> void:
		if !dict.has(key): return
		dict.erase(key)
		emit_signal("key_deleted", key)
		
	func _to_string() -> String:
		return str(dict)
		

class NodeInfo extends Resource:
	export var blocks 		: Resource 		= UnicDict.new()
	
	func has_block(key : String) -> bool:
		return blocks.has(key)
	
	func get_blocks_list() -> Array:
		return blocks.keys()
	
	func get_block(key : String) -> NodeBlockInfo:
		return blocks.get_value(key)


class NodeBlockInfo extends Resource:
	pass


class Personed_NBI extends NodeBlockInfo:
	export var person : String


class NBI_Text extends Personed_NBI:
	export var font_locale_key	: String
	export var text_locale_key 	: String


class NBI_MoodGroup extends Personed_NBI:
	export var group		: String


class NBI_Mood extends NBI_MoodGroup:
	export var mood			: String
	export var align		: int	 = -1


class NBI_Branch extends NodeBlockInfo:
	export var defalut_id 		: int		= -1
	export var conditions		: Array


class NBI_Choose extends NBI_Branch:
	export var option_names 	: Array
	
	
class NBI_NextDialog extends NodeBlockInfo:
	export var dialog_name 	: String

#---

class MoodInfo extends Resource:
	export var textures : Resource = UnicDict.new()
	
	func has_group(group_name : String) -> bool:
		return group_name in get_groups_list()
	
	func get_groups_list() -> Array:
		return textures.keys()
	
	func get_mood_texture(group_name : String) -> Texture:
		var group_info = textures.get_value(group_name)
		
		if !group_info is Array: return null
		
		if group_name in textures.keys(): return group_info[0]
		return null
	
	func get_mood_file_path(group_name : String) -> String:
		var group_info = textures.get_value(group_name)
		
		if !group_info is Array: return ""
		
		if group_name in textures.keys(): return group_info[1]
		return ""

#---

class PersonProfile extends Resource:
	enum ALIGN_LIST {LEFT, CENTER, RIGHT}
	
	export (ALIGN_LIST) var defalut_align
	export 				var defalut_font_locale_key	: String
	export				var person_name_locale_key 	: String
	export 				var moods 					: Resource = UnicDict.new()
	
	func get_mood_list() -> Array:
		return moods.keys()
	
	func get_mood_info(mood_name : String) -> MoodInfo:
		return moods.get_value(mood_name)
	
	func get_mood_texture(mood_name : String, group_name : String) -> Texture:
		var mood_info = get_mood_info(mood_name)
		
		if !is_instance_valid(mood_info): return null
		
		return mood_info.get_mood_texture(group_name)
		
	func get_groups_list() -> Array:
		var groups = []
		
		for mood in moods.keys():
			var mood_info = get_mood_info(mood)
			for group_name in mood_info.get_groups_list():
				if !groups.has(group_name): groups.append(group_name)
		
		return groups

#---

class DialogData extends Resource:
	export var node_list		: Resource = UnicDict.new()
	export var node_connections	: Array # {from_node, to_node, from_slot}
	export var start_nodes		: Array
	
	func has_node(node_name : String) -> bool:
		return node_name in node_list.keys()
		
	func get_node(node_name : String) -> NodeInfo:
		return node_list.get_value(node_name)
		
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
	
	func is_nodes_connected(from_node_name : String, to_node_name : String, from_port : int) -> bool:
		if !has_node(from_node_name) || !has_node(to_node_name): return false
		
		return {"from_node" : from_node_name, "to_node" : to_node_name, "from_slot" : from_port} in node_connections
		
	func _to_string() -> String:
		return "{Nodes: " + str(node_list) +", Connections: " + str(node_connections) + ", StartNodes: " + str(start_nodes) + "}"
	

class FontInfo extends Resource:
	enum TYPE {NORMAL, ITALIC, BOLD, ITALIC_BOLD}
	
	export var normal 		: DynamicFont = DynamicFont.new()
	export var italic		: DynamicFont = DynamicFont.new()
	export var bold			: DynamicFont = DynamicFont.new()
	export var italic_bold	: DynamicFont = DynamicFont.new()
	
	export var normal_fontdata_path 		: String
	export var italic_fontdata_path 		: String
	export var bold_fontdata_path 			: String
	export var italic_bold_fontdata_path 	: String
	
	func get_font_type(type : int) -> DynamicFont:
		match type:
			TYPE.NORMAL:
				return normal
			TYPE.BOLD:
				return bold
			TYPE.ITALIC:
				return italic
			TYPE.ITALIC_BOLD:
				return italic_bold
			_:
				return null
	

class LangInfo extends Resource:
	export var translation_res 		: Translation 	= Translation.new()
	export var defalut_font_name	: String



func get_align_name(index : int) -> String:
	if index >= PersonProfile.ALIGN_LIST.keys().size() && index < 0: return ""
	return PersonProfile.ALIGN_LIST.keys()[index]


func get_align_names_list() -> PoolStringArray:
	return PoolStringArray(PersonProfile.ALIGN_LIST.keys())
	
	
func return_boolean(expression : bool) -> bool:
	return expression

