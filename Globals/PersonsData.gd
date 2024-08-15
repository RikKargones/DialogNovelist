extends Node


func get_person_dict() -> UnicDict:
	if !is_instance_valid(Project): return UnicDict.new()
	return Project.get_project_info().persons_data as UnicDict


func get_persons_list() -> Array:
	return get_person_dict().keys()


func get_personinfo(person_name : String) -> EditorPersonInfo:
	return get_person_dict().get_value(person_name)


func add_person(person_key : String) -> void:
	get_person_dict().add_key(person_key, EditorPersonInfo.new(person_key))
	

func rename_person(old_name : String, new_name : String) -> void:
	get_person_dict().rename_key(old_name, new_name)

	
func erase_person(person_key : String) -> void:
	get_person_dict().erase(person_key)
