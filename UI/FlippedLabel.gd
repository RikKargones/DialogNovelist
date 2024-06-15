extends Label

class_name SidedLabel

export var face_left = false

func _physics_process(delta):
	var parent = get_parent()
	
	if is_instance_valid(parent):
		if parent is Control:
			rect_min_size.x = parent.rect_size.y
			rect_min_size.y = parent.rect_size.x
			rect_size = Vector2()
			if face_left:
				rect_rotation 	= 270
				rect_position.y = parent.rect_size.y
			else:
				rect_rotation	= 90
				rect_position.x = parent.rect_size.x			
