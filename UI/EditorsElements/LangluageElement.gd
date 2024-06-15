extends PanelContainer

onready var checkmark_button 	= $Panel/Enable
onready var lang_label			= $Panel/LangName
onready var font_button			= $Panel/FontSelect

var locale_short 	: String
var locale 			: String


func _ready():
	font_button.connect_to_unicdict(FontsData.font_dict)
	checkmark_button.connect("toggled", self, "on_checkmark_toggled")


func set_locale(new_locale_short : String) -> void:
	if LocalesData.get_locale_long(new_locale_short) == "":
		LocalesData.erase_locale(locale)
		queue_free()
	
	checkmark_button.disabled 	= new_locale_short in LocalesData.defalut_locales
	checkmark_button.pressed 	= new_locale_short in LocalesData.defalut_locales
	lang_label.text 			= LocalesData.get_locale_long(new_locale_short)
	
	if checkmark_button.pressed:
		var def_font = LocalesData.get_locale_defalut_font(locale)
		
		LocalesData.erase_locale(locale)
		LocalesData.add_locale(new_locale_short)
		
		locale = LocalesData.get_locale_long(new_locale_short)
		locale_short = new_locale_short
		
		set_font(def_font)


func set_font(font_name : String) -> void:
	LocalesData.set_locale_defalut_font(locale, font_name)


func erase_confurmed() -> void:
	LocalesData.erase_locale(locale_short)
	checkmark_button.disconnect("toggled", self, "on_checkmark_toggled")
	checkmark_button.pressed = false
	checkmark_button.connect("toggled", self, "on_checkmark_toggled")


func on_checkmark_toggled(button_pressed : bool) -> void:
	if button_pressed:
		LocalesData.add_locale(locale_short, font_button.get_selected_item_text())
	else:
		checkmark_button.pressed = true
		var popup = ConfirmPopup.new("Are you sure you want erase this langluage?\nIt will erase ALL translations for this langluage in project.")
		Ui.add_popup(popup, "confirmed", self, "erase_confurmed")


func search_call(search_line : String) -> void:
	visible = (search_line.strip_edges() == "" || locale_short.begins_with(search_line) || locale.begins_with(search_line))


func _on_FontSelect_item_selected(item_name : String) -> void:
	set_font(item_name)
