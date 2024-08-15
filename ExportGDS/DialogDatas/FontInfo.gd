extends Resource

class_name FontInfo

enum TYPE {NORMAL, ITALIC, BOLD, ITALIC_BOLD}
	
export (DynamicFont) 	var normal 					: DynamicFont 		= DynamicFont.new()
export (DynamicFont) 	var italic					: DynamicFont 		= DynamicFont.new()
export (DynamicFont) 	var bold					: DynamicFont 		= DynamicFont.new()
export (DynamicFont) 	var italic_bold				: DynamicFont 		= DynamicFont.new()

func get_font_type(type : int) -> DynamicFont:
	match type:
		TYPE.NORMAL:
			return normal
		TYPE.BOLD:
			return bold
		TYPE.ITALIC:
			return italic
		TYPE.ITALIC_BOLD:
			return italic_bold
		_:
			return null

