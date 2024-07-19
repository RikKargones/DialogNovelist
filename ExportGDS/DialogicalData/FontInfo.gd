extends Resource

class_name FontInfo

enum TYPE {NORMAL, ITALIC, BOLD, ITALIC_BOLD}
	
export var normal 		: DynamicFont = DynamicFont.new()
export var italic		: DynamicFont = DynamicFont.new()
export var bold			: DynamicFont = DynamicFont.new()
export var italic_bold	: DynamicFont = DynamicFont.new()

export var normal_fontdata_path 		: String
export var italic_fontdata_path 		: String
export var bold_fontdata_path 			: String
export var italic_bold_fontdata_path 	: String

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
