extends Node

var try_show_popups = false
var popups 			= []

class ConnectInfo:
	var object 		: Object
	var obj_func 	: String
	var args 		: Array
	
	func _init(to_object : Object, obj_function : String, additional_args : Array = []) -> void:
		object = to_object
		obj_func = obj_function
		args = additional_args
	
	func is_valid() -> bool:
		return is_instance_valid(object) && object.has_method(obj_func)
	
	func connect_to_object(other_object : Object, obj_signal : String) -> void:
		if !is_valid() || !is_instance_valid(other_object) || !other_object.has_signal(obj_signal): return
		
		other_object.connect(obj_signal, object, obj_func, args)


func add_popup(popup : Popup) -> void:
	popups.append(popup)
	
	if !is_inside_tree(): 
		try_show_popups = true
		return
		
	add_popup_to_tree(popup)
	

func add_popup_to_tree(popup : Popup) -> void:
	get_tree().current_scene.call_deferred("add_child", popup)
	
	popup.connect("hide", self, "remove_popup", [popup])
	popup.connect("ready", popup, "popup_centered", [], CONNECT_ONESHOT)
	popup.connect("ready", popup, "set_as_minsize", [], CONNECT_ONESHOT)


func _process(delta):
	if try_show_popups && is_inside_tree():
		try_show_popups = false
		
		for popup in popups:
			if is_instance_valid(popup) && !popup.is_inside_tree():
				add_popup_to_tree(popup)


func is_valid_connect_target(connect_info : ConnectInfo) -> bool:
	if !is_instance_valid(connect_info):
		popup_error("Connect info not seted!", "UI")
		return false
	
	if !connect_info.is_valid():
		popup_error("Can't add confirm popup because object or func to callback is not existing.", "UI")
		return false
		
	return true

func popup_error(text : String, trower_name : String = ""):
	if trower_name == "": add_popup(ErrorPopup.new(text))
	else: add_popup(ErrorPopup.new(trower_name + ": " + text))


func popup_confirm(connect_info : ConnectInfo, popup_text : String = "") -> void:
	if !is_valid_connect_target(connect_info): return
		
	var new_popup = ConfirmPopup.new(popup_text)
	connect_info.connect_to_object(new_popup, "confirmed")
	add_popup(new_popup)


func popup_fileshow(connect_info : ConnectInfo, title = "Get a file...", file_filters = PoolStringArray([]), pick_mode = FileDialog.MODE_OPEN_FILE) -> void:
	if !is_valid_connect_target(connect_info): return
	
	var new_popup = FilePopup.new(title, file_filters, pick_mode)
	
	match pick_mode:
		FileDialog.MODE_OPEN_FILE, FileDialog.MODE_SAVE_FILE, FileDialog.MODE_OPEN_ANY:
			connect_info.connect_to_object(new_popup, "file_selected")
		FileDialog.MODE_OPEN_DIR, FileDialog.MODE_OPEN_ANY:
			connect_info.connect_to_object(new_popup, "dir_selected")
		FileDialog.MODE_OPEN_FILES:
			connect_info.connect_to_object(new_popup, "files_selected")
			
	add_popup(new_popup)
	

func popup_namer(connect_info : ConnectInfo, title : String = "Name someting...", filters_arr : PoolStringArray = PoolStringArray([]), before_text : String = "", validate : bool = false) -> void:
	if !is_valid_connect_target(connect_info): return
	
	var new_popup = NameDialog.new(title, filters_arr, before_text, validate)
	
	connect_info.connect_to_object(new_popup, "name_confurmed")
	
	add_popup(new_popup)

	
func remove_popup(popup : Popup) -> void:
	popups.erase(popup)
	popup.queue_free()
