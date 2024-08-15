extends Resource

class_name TimeStamp

export (int) var time_minutes 	: int
export (int) var time_hours		: int
export (int) var time_day		: int
export (int) var time_month		: int
export (int) var time_year		: int
export (int) var time_weekday	: int

func _init() -> void:
	var time = Time.get_time_dict_from_system()
	var date = Time.get_date_dict_from_system()
	
	time_minutes 	= time.minute
	time_hours 		= time.hour
	time_year		= date.year
	time_month		= date.month
	time_day		= date.day
	time_weekday	= date.weekday
	
