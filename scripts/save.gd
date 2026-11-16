extends Node

const SAVE_PATH := "user://save.bin"

func save_data() -> void:
	var data := {}
	for player in get_tree().get_nodes_in_group("players") + get_tree().get_nodes_in_group("save"):
		data[player.get_path()] = player.save_dict()
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("FileAccess open", SAVE_PATH, "for write failed", FileAccess.get_open_error())
		return
	
	file.store_var(data)
	file.close()
	
	DebugLayer.just_saved = true

func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("FileAccess open", SAVE_PATH, "for read failed", FileAccess.get_open_error())
		return
	
	var data: Dictionary = file.get_var(true)
	for key in data:
		var node := get_node(key)
		node.load_dict(data[key])

func delete_save_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var code = DirAccess.remove_absolute(SAVE_PATH)
		if code != OK:
			push_error("DirAccess delete", SAVE_PATH, "failed", DirAccess.get_open_error())
