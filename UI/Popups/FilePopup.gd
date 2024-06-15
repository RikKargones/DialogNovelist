extends FileDialog

class_name FilePopup

func _init(title = "Get a file...", file_filters = PoolStringArray([]), pick_mode = FileDialog.MODE_OPEN_FILE):
	mode_overrides_title = false
	window_title = title
	filters = file_filters
	mode = pick_mode
	rect_min_size = Vector2(500, 400)
	access = FileDialog.ACCESS_FILESYSTEM
	
