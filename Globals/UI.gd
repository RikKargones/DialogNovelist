extends Node

var try_show_popups = false
var popups 			= []

func add_popup(popup : Popup, popup_signal = "", inst = null, method_name = "", add_vars = []) -> void:
	if is_instance_valid(inst) && inst.has_method(method_name) && popup.has_signal(popup_signal):
		popup.connect(popup_signal, inst, method_name, add_vars)
	elif popup_signal != "" && method_name != "":
		popup_error("Popup can't connect to instance! (" + str(popup) + ")")
	
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


func popup_error(text : String, trower_name : String = ""):
	if trower_name == "": add_popup(ErrorPopup.new(text))
	else: add_popup(ErrorPopup.new(trower_name + ": " + text))

	
func remove_popup(popup : Popup) -> void:
	popups.erase(popup)
	popup.queue_free()
