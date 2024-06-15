extends Node

var person_dict	: DialogDispetcher.UnicDict = DialogDispetcher.UnicDict.new()

func get_persons_list() -> Array:
	return person_dict.keys()


func get_personinfo(person_name : String) -> EditorPersonInfo:
	return person_dict.get_value(person_name)


func add_person(person_key : String) -> void:
	person_dict.add_key(person_key, EditorPersonInfo.new(person_key))
	

func rename_person(old_name : String, new_name : String) -> void:
	person_dict.rename_key(old_name, new_name)

	
func erase_person(person_key : String) -> void:
	person_dict.erase(person_key)
