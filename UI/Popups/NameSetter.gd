extends ConfirmationDialog

class_name NameDialog

var hb_con			: HBoxContainer = HBoxContainer.new()
var line_edit 		: LineEdit = LineEdit.new()

var filters 		= PoolStringArray([])
var validate_names	= false

signal name_confurmed(new_name)


func _init(title : String, filters_arr : PoolStringArray, before_text : String, validate : bool):
	add_child(hb_con)
	
	if before_text.strip_edges() != "":
		var bef_text = Label.new()
		hb_con.add_child(bef_text)
		bef_text.text = before_text
	
	hb_con.add_child(line_edit)
	line_edit.rect_min_size.x = 200
	
	filters = filters_arr
	validate_names = validate
	
	window_title = title
	
	line_edit.size_flags_horizontal = SIZE_EXPAND_FILL	
	line_edit.connect("text_changed", self, "on_line_edit_text_changed")
	line_edit.connect("text_entered", self, "return_confurmed_name")
	
	get_ok().disabled = true
	
	connect("confirmed", self, "return_confurmed_name")

func on_line_edit_text_changed(new_text : String):
	get_ok().disabled = new_text in filters || new_text.strip_edges() == ""
	
	if validate_names:
		get_ok().disabled = get_ok().disabled || !new_text.is_valid_identifier()
		

func return_confurmed_name(_text = ""):
	if get_ok().disabled: return
	
	emit_signal("name_confurmed", line_edit.text)
	hide()
