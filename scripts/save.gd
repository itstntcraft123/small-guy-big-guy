extends Node

const SAVE_PATH := "user://save.bin"
const CONFIG_PATH := "user://config.cfg"

func save_game() -> void:
	var data := get_game_save()
	for node in get_tree().get_nodes_in_group("players") + get_tree().get_nodes_in_group("save"):
		data[node.get_path()] = node.save_dict()
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("FileAccess open", SAVE_PATH, "for write failed", FileAccess.get_open_error())
		return
	
	file.store_var(data)
	file.close()
	
	DebugLayer.just_saved = true

func load_game() -> void:
	var data := get_game_save()
	for key in data:
		#if settings_only and str(key) != "/root/Settings":
			#continue
		var node := get_node(key)
		if node != null:
			node.load_dict(data[key])

func get_game_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("FileAccess open", SAVE_PATH, "for read failed", FileAccess.get_open_error())
		return {}
	
	return file.get_var(false)

func delete_game_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var result = DirAccess.remove_absolute(SAVE_PATH)
		if result != OK:
			push_error("DirAccess delete", SAVE_PATH, "failed", DirAccess.get_open_error())


func save_cfg() -> void:
	var config := ConfigFile.new()
	var data: Dictionary = Settings.save_dict()
	for key in data:
		config.set_value("Settings", key, data[key])
	config.save(CONFIG_PATH)
	
	DebugLayer.just_saved = true

func load_cfg() -> void:
	var config = ConfigFile.new()
	var result = config.load(CONFIG_PATH)
	if result != OK:
		push_error("ConfigFile load", CONFIG_PATH, "failed")
		return
	
	var data := {}
	for key in config.get_section_keys("Settings"):
		data[key] = config.get_value("Settings", key)
	Settings.load_dict(data)
