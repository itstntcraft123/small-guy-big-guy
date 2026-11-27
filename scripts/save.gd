extends Node

const LEVEL_PATH := "user://level.bin" # "level progress" (stores positions of players in a level)
const SAVE_PATH := "user://save.bin" # "game progress" (stores level number)
const CONFIG_PATH := "user://config.cfg" # "config" (stores user config like fullscreen)
const BACKUPS_DIR := "user://backups/"

func save_game() -> void:
	if !Settings.save_in_level:
		return
	
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
	if !FileAccess.file_exists(LEVEL_PATH) or !Settings.save_in_level:
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
	
	var result := config.save(CONFIG_PATH)
	if result != OK:
		push_error("ConfigFile save ", CONFIG_PATH, " failed ", result)
		return
	
	DebugLayer.just_saved = true

func load_cfg() -> void:
	if !FileAccess.file_exists(CONFIG_PATH):
		return
	
	var config = ConfigFile.new()
	var result = config.load(CONFIG_PATH)
	if result != OK:
		push_error("ConfigFile load ", CONFIG_PATH, " failed ", result)
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
	if !FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("FileAccess open ", LEVEL_PATH, " for read failed ", FileAccess.get_open_error())
		return
	
	Gamemgr.level = file.get_var(false)

func delete_progress() -> void:
	if !FileAccess.file_exists(SAVE_PATH):
		return
	
	var result = DirAccess.remove_absolute(SAVE_PATH)
	if result != OK:
		push_error("DirAccess delete ", SAVE_PATH, " failed ", DirAccess.get_open_error())


func create_backup(backup_name: String, config: bool = true, game: bool = true, level: bool = true) -> void:
	if !DirAccess.dir_exists_absolute(BACKUPS_DIR):
		var dir_result = DirAccess.make_dir_absolute(BACKUPS_DIR)
		if dir_result != OK:
			push_error("DirAccess create ", BACKUPS_DIR, " failed ", DirAccess.get_open_error())
			return
	
	var time := int(Time.get_unix_time_from_system())
	var path := BACKUPS_DIR + str(time)
	# add numbers to path until a valid path is found
	while FileAccess.file_exists(path):
		if path.contains("x") and path.substr(path.rfind("x") + 1).is_valid_int():
			path = path.left(path.rfind("x") + 1) + str(int(path.substr(path.rfind("x"))) + 1)
		else:
			path += "x0"
		if len(path.trim_prefix(BACKUPS_DIR)) > 20:
			push_error("Path too long")
			return
	
	var zip := ZIPPacker.new()
	var zip_result = zip.open(path + ".zip")
	if zip_result != OK:
		push_error("ZIPPacker open ", path + ".zip", " failed")
		return
	
	config = Utils.write_zip_from_file(zip, CONFIG_PATH, config)
	game = Utils.write_zip_from_file(zip, SAVE_PATH, game)
	level = Utils.write_zip_from_file(zip, LEVEL_PATH, level)
	
	var cfg := ConfigFile.new()
	var data := {
		"name": backup_name,
		"unix": time,
		"config": config,
		"game": game,
		"level": level
	}
	for key in data:
		cfg.set_value("Metadata", key, data[key])
	Utils.write_zip(zip, "metadata.txt", cfg.encode_to_text().to_utf8_buffer())
	
	zip.close()
	
	var result = cfg.save(path + ".txt")
	if result != OK:
		push_error("Configfile save ", path + ".txt", " failed ", result)
