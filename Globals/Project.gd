extends Node

var project_save_info		: ProjectSaveInfo	= ProjectSaveInfo.new()
var project_info			: ProjectData 		= ProjectData.new()
var current_edit_locale 	: String 			= LocalesData.LocalesNames.en
var translate_edit_locale 	: String 			= LocalesData.LocalesNames.ru

var has_unsaved_changes 	: bool = true

signal edit_locale_changed
signal translate_edit_locale_changed


func _ready():
	project_info.connect("changed", self, "on_project_update")


func on_project_update() -> void:
	has_unsaved_changes = true
	
	
func is_project_saved() -> bool:
	return !has_unsaved_changes


func get_project_info() -> ProjectData:
	if !is_instance_valid(project_info):
		project_info = ProjectData.new()
	return project_info


func set_current_edit_locale(locale : String) -> void:
	if Project.get_project_info().locales_data.has(locale):
		current_edit_locale = locale
		emit_signal("edit_locale_changed", locale)
	
	
func set_translate_edit_locale(locale : String) -> void:
	if  Project.get_project_info().locales_data.has(locale):
		translate_edit_locale = locale	
		emit_signal("translate_edit_locale_changed", locale)


func _notification(what) -> void:
	if MainLoop.NOTIFICATION_WM_QUIT_REQUEST == what:
		if is_project_saved():
			get_tree().quit()
		else:
			var connect_info = Ui.ConnectInfo.new(get_tree(), "quit")
			Ui.popup_confirm(connect_info, "Project has unsaved changes!\nQuit anyway?")


func request_quit_app() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
