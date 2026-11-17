extends Node2D

@export var game_menu: PackedScene
var just_exited_game_menu := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and Settings.r_to_restart and !get_tree().paused:
		restart_level()
		return
	if event.is_action_pressed("ui_cancel") and !has_node("CanvasLayer/EscapeScreen"):
		if just_exited_game_menu:
			just_exited_game_menu = false
		else:
			$CanvasLayer.add_child(game_menu.instantiate())
			Save.save_game()
			get_tree().paused = true

func restart_level() -> void:
	Save.delete_game_save()
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _ready() -> void:
	Save.load_game()

func _on_autosave_timeout() -> void:
	Save.save_game()
