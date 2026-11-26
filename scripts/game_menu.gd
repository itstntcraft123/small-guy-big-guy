extends Control

@export var options_menu: PackedScene 

func exit() -> void:
	get_tree().paused = false
	$"../..".reset_timer()
	queue_free()

func _on_select_menu_button_selected(item: Control) -> void:
	match item.name:
		"BackToGame":
			exit()
		"Restart":
			Save.delete_game_save()
			get_tree().paused = false
			Gamemgr.load_current_level()
		"Reset":
			Save.delete_progress()
			Save.delete_game_save()
			get_tree().paused = false
			Gamemgr.load_level(1)
		"Options":
			add_child(options_menu.instantiate())
			$MarginContainer.hide()
		"Quit":
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func unhide() -> void:
	$MarginContainer.show()
	$MarginContainer/VBoxContainer/SelectMenu/Options.grab_focus()
