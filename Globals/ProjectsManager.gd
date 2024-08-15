extends Node

var projects_list_path 	: String		= "user://ProjectsList.txt"
var projects 			: Array


func _ready() -> void:
	load_project_list()
	

func create_empty_project_list_file() -> void:
	var file : File = File.new()
	
	file.open(projects_list_path, File.WRITE)
	file.store_var({})
	file.close()


func load_project_list() -> void:
	var dir 	: Directory = Directory.new()
	var file 	: File		= File.new()
	
	projects.clear()
	
	if file.open(projects_list_path, File.READ) != OK || file.get_position() == file.get_len():
		create_empty_project_list_file()
		return
	
	var list = file.get_var()
	
	file.close()
	
	if typeof(list) != TYPE_DICTIONARY:
		create_empty_project_list_file()
		return
	
	list = list as Dictionary
	
	for project_name in list.keys():
		var project_path = list[project_name]
		
		if !project_path is String: continue
		
		project_path = project_path as String
		
		var dir_path 			: String 			= project_path.get_base_dir()
		var new_project_save 	: ProjectSaveInfo 	= ProjectSaveInfo.new()
		
		new_project_save.project_metadata.project_name 			= project_name
		new_project_save.project_metadata.project_save_version 	= "???"
		
		new_project_save.project_path = project_path
		
		if !dir.file_exists(project_path):
			new_project_save.status = ProjectSaveInfo.PROJECT_STATUS.PROJECT_NOT_EXIST
		else:
			var res_file = ResourceLoader.load(project_path, "ProjectMetadata", true) as ProjectMetadata
			
			if !is_instance_valid(ProjectMetadata) || !res_file is ProjectMetadata || !dir.file_exists(dir_path.plus_file("ProjectData.tres")):
				new_project_save.status = ProjectSaveInfo.PROJECT_STATUS.PROJECT_CORRUPTED
			elif res_file.project_save_version != Constants.version:
				new_project_save.status = ProjectSaveInfo.PROJECT_STATUS.PROJECT_OLD_VERSION
				new_project_save.project_metadata = res_file
			else:
				new_project_save.status = ProjectSaveInfo.PROJECT_STATUS.PROJECT_VALID
				new_project_save.project_metadata = res_file
		
		projects.append(new_project_save)
		

func save_project_list() -> void:
	var file = File.new()
	
	var project_save_lists = {}
	
	for project_save_info in projects:
		if project_save_info is ProjectSaveInfo:
			project_save_lists[project_save_info.project_metadata.project_name] = project_save_info.project_path
	
	if file.open(projects_list_path, File.WRITE) != OK:
		Ui.popup_error("Can't save project lists!")
		return
	
	file.store_var(project_save_lists)
	file.close()
	
		
func create_empty_project(path : String) -> ProjectSaveInfo:
	match EditLibraly.checkout_path(path):
		EditLibraly.PATH_RESULTS.FILE_EXIST:
			Ui.popup_error("Can't save project on path:\n" + path + "\nIt's alredy exist!")
			return null
		EditLibraly.PATH_RESULTS.CANT_OPEN_DIR:
			Ui.popup_error("Can't save project on path:\n" + path + "\nCan't open desired directory!")
			return null
		EditLibraly.PATH_RESULTS.DIR_NOT_EXIST:
			var dir = Directory.new()
			dir.make_dir_recursive(path.get_base_dir())
		EditLibraly.PATH_RESULTS.FOLDER_HAS_FILES:
			Ui.popup_error("Can't save project on path:\n" + path + "\nBecouse directory is not empty!")
			return null
		EditLibraly.PATH_RESULTS.FOLDER_EMPTY:
			pass
		_:
			Ui.popup_error("Can't save project on path:\n" + path + "\nIncorrect\\invalid path!")
			return null
	
	var new_project_save_info 	: ProjectSaveInfo 	= ProjectSaveInfo.new()
	var new_project_data		: ProjectData		= ProjectData.new()
	
	new_project_save_info.project_path 						= path
	new_project_save_info.project_metadata.project_name 	= path.get_file().rsplit(path.get_extension(), true, 1)[0]
	new_project_save_info.status 							= ProjectSaveInfo.PROJECT_STATUS.PROJECT_VALID
	
	if !Exporter.save_project(new_project_save_info, new_project_data):
		Ui.popup_error("Project save failed.")
		return null
	
	projects.append(new_project_save_info)
	
	return new_project_save_info

	
