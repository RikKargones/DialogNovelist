extends ConfirmationDialog

class_name ConfirmPopup

var text_line = Label.new()

func _init(text : String):
	add_child(text_line)
	text_line.align = Label.ALIGN_CENTER
	text_line.size_flags_horizontal = SIZE_EXPAND_FILL
	text_line.text = text

