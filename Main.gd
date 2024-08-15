extends PanelContainer

onready var editor_tabs = $List/Scroll/Editors


func _on_DiaBt_pressed() -> void:
	editor_tabs.current_tab = 0
	

func _on_FontBt_pressed():
	editor_tabs.current_tab = 1


func _on_VarBt_pressed():
	editor_tabs.current_tab = 2


func _on_PersBt_pressed():
	editor_tabs.current_tab = 3


func _on_LangBt_pressed():
	editor_tabs.current_tab = 4


func _on_PrevBt_pressed():
	editor_tabs.current_tab = 5
