extends Button

class_name HideButton

export var is_hide 				: bool		= false

export var hide_node 			: NodePath
export var replace_node 		: NodePath

export var on_hide_text 		: String
export var on_show_text			: String

export var enable_side_label 	: bool

var side_label : SidedLabel

signal hide_hidable_node
signal show_hidable_node


func _ready():
	var cur_hide 		= get_node_or_null(hide_node)
	var replace_hide 	= get_node_or_null(replace_node)
	
	if enable_side_label:
		side_label = SidedLabel.new()
		side_label.clip_text = clip_text
		side_label.align = align
		add_child(side_label)
	
	text = " "
	
	if cur_hide is Control:
		connect("hide_hidable_node", cur_hide, "set", ["visible", false])
		connect("show_hidable_node", cur_hide, "set", ["visible", true])
		
	if replace_hide is Control:
		connect("hide_hidable_node", replace_hide, "set", ["visible", true])
		connect("show_hidable_node", replace_hide, "set", ["visible", false])
	
	update()
	

func update() -> void:
	if is_hide:
		if is_instance_valid(side_label): side_label.text = on_hide_text
		else: text = on_hide_text
		emit_signal("hide_hidable_node")
	else:
		if is_instance_valid(side_label): side_label.text = on_show_text
		else: text = on_show_text
		emit_signal("show_hidable_node")


func _pressed() -> void:
	is_hide = !is_hide
	update()
