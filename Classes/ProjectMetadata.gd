extends Resource

class_name ProjectMetadata

export (String) 	var project_name 			: String
export (String)		var project_save_version	: String		= Constants.version

export (Resource)	var create_timestamp		: Resource		= TimeStamp.new()
export (Resource)	var save_timestamp			: Resource		= TimeStamp.new()
