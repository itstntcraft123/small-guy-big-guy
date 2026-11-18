extends Node

var level: int = 1
@onready var levels := DirAccess.get_files_at("res://scenes/levels")

func _ready() -> void:
	Save.load_progress()
	Save.save_progress()

func load_current_level() -> void:
	load_level(level)

func next_level() -> void:
	level += 1
	Save.delete_game_save()
	Save.save_progress()
	load_current_level()

func load_level(level_num: int):
	level = level_num
	get_tree().change_scene_to_file("res://scenes/levels/" + levels[clampi(level_num, 1, len(levels)) - 1])
	Save.save_progress()
