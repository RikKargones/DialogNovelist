extends Resource

class_name ProjectSaveInfo

enum PROJECT_STATUS {
	PROJECT_INVALID = -1,
	PROJECT_VALID = 0,
	PROJECT_NOT_EXIST = 1,
	PROJECT_CORRUPTED = 2,
	PROJECT_OLD_VERSION = 3,
}

export (PROJECT_STATUS) 			var status 				: int 		= PROJECT_STATUS.PROJECT_INVALID
export (String, FILE, "*.tres") 	var project_path		: String	= ""
export (Resource)					var project_metadata	: Resource	= ProjectMetadata.new()
