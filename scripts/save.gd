extends Node

func save_data() -> void:
	var data := {}
	for player in get_tree().get_nodes_in_group("players") + get_tree().get_nodes_in_group("save"):
		data[player.get_path()] = player.save_dict()
	
	var file = FileAccess.open("user://save.bin", FileAccess.WRITE)
	if file == null:
		push_error("FileAccess open user://save.bin for write failed", FileAccess.get_open_error())
		return
	
	file.store_var(data)
	file.close()

func load_save() -> void:
	if not FileAccess.file_exists("user://save.bin"):
		return
	
	var file = FileAccess.open("user://save.bin", FileAccess.READ)
	if file == null:
		push_error("FileAccess open user://save.bin for read failed", FileAccess.get_open_error())
		return
	
	var data: Dictionary = file.get_var(true)
	for key in data:
		var node := get_node(key)
		node.load_dict(data[key])
