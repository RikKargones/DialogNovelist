extends AcceptDialog

class_name ErrorPopup

func _init(text : String):
	var time_stamp 	= Time.get_time_dict_from_system()
	var t_hour 		= str(time_stamp["hour"])
	var t_minute 	= str(time_stamp["minute"])
	var t_seconds 	= str(time_stamp["second"])
	
	if t_hour.length() < 2: 	t_hour 		= "0" + t_hour
	if t_minute.length() < 2: 	t_minute 	= "0" + t_minute
	if t_seconds.length() < 2: 	t_seconds 	= "0" + t_seconds
	
	var time_text = "Time: " + t_hour + ":" + t_minute + ":" + t_seconds
	
	var margin_con 	= MarginContainer.new()
	var vb_con		= VBoxContainer.new()
	var time_label	= Label.new()
	var text_label	= Label.new()
	
	window_title = "Error!"
	popup_exclusive = true
	
	add_child(margin_con)
	margin_con.add_child(vb_con)
	vb_con.add_child(time_label)
	vb_con.add_child(HSeparator.new())
	vb_con.add_child(text_label)
	vb_con.add_child(HSeparator.new())
	
	margin_con.set("custom_constants/margin_right", 10)
	margin_con.set("custom_constants/margin_left", 10)
	margin_con.set("custom_constants/margin_bottom", 10)
	vb_con.set("custom_constants/separation", 10)
	
	time_label.align = Label.ALIGN_CENTER
	text_label.align = Label.ALIGN_CENTER
	
	time_label.text = time_text
	text_label.text = text
	
