extends Node

func save_project(project_saveinfo : ProjectSaveInfo, project_data : ProjectData) -> bool:
	var path : String = project_saveinfo.project_path
	
	match EditLibraly.checkout_path(path):
		EditLibraly.PATH_RESULTS.CANT_OPEN_DIR:
			Ui.popup_error("Can't save project on path:\n" + path + "\nCan't open desired directory!")
			return false
		EditLibraly.PATH_RESULTS.FOLDER_HAS_FILES:
			EditLibraly.erase_folder_recursive(path.get_base_dir())
			continue
		EditLibraly.PATH_RESULTS.DIR_NOT_EXIST, EditLibraly.PATH_RESULTS.FOLDER_HAS_FILES:
			var dir = Directory.new()
			dir.make_dir_recursive(path.get_base_dir())
		EditLibraly.PATH_RESULTS.FOLDER_EMPTY, EditLibraly.PATH_RESULTS.FILE_EXIST:
			pass
		_:
			Ui.popup_error("Can't save project on path:\n" + path + "\nIncorrect\\invalid path!")
			return false
	
	ResourceSaver.save(path, Project.project_save_info.project_metadata)
	ResourceSaver.save(path.get_base_dir().plus_file("ProjectData.tres"), Project.project_info)	
	
	return true
