extends FileDialog

class_name FilePopup

func _init(title : String, file_filters : PoolStringArray, pick_mode : int):
	mode_overrides_title = false
	window_title = title
	filters = file_filters
	mode = pick_mode
	rect_min_size = Vector2(500, 400)
	access = FileDialog.ACCESS_FILESYSTEM
	
