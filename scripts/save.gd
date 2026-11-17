extends Node

const LEVEL_PATH := "user://level.bin" # stores positions of players in a level
const SAVE_PATH := "user://save.bin" # stores level number
const CONFIG_PATH := "user://config.cfg" # stores user config like fullscreen

func save_game() -> void:
	var data := get_game_save()
	for node in get_tree().get_nodes_in_group("players") + get_tree().get_nodes_in_group("save"):
		data[node.get_path()] = node.save_dict()
	
	var file = FileAccess.open(LEVEL_PATH, FileAccess.WRITE)
	if file == null:
		push_error("FileAccess open ", LEVEL_PATH, " for write failed ", FileAccess.get_open_error())
		return
	
	file.store_var(data)
	file.close()
	
	DebugLayer.just_saved = true

func load_game() -> void:
	var data := get_game_save()
	for key in data:
		var node := get_node(key)
		if node != null:
			node.load_dict(data[key])

func get_game_save() -> Dictionary:
	if not FileAccess.file_exists(LEVEL_PATH):
		return {}
	
	var file = FileAccess.open(LEVEL_PATH, FileAccess.READ)
	if file == null:
		push_error("FileAccess open ", LEVEL_PATH, " for read failed ", FileAccess.get_open_error())
		return {}
	
	return file.get_var(false)

func delete_game_save() -> void:
	if FileAccess.file_exists(LEVEL_PATH):
		var result = DirAccess.remove_absolute(LEVEL_PATH)
		if result != OK:
			push_error("DirAccess delete ", LEVEL_PATH, " failed ", DirAccess.get_open_error())


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


func save_progress() -> void:
	var level: int = Gamemgr.level
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("FileAccess open ", SAVE_PATH, " for write failed" , FileAccess.get_open_error())
		return
	
	file.store_var(level)
	file.close()
	
	DebugLayer.just_saved = true

func load_progress() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("FileAccess open ", LEVEL_PATH, " for read failed ", FileAccess.get_open_error())
		return
	
	Gamemgr.level = file.get_var(false)
