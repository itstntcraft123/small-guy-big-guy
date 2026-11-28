extends MarginContainer

func exit() -> void:
	$"../MarginContainer".show()
	$"../%Cheats".grab_focus()
	get_parent().refresh_visible()
	queue_free()

func _on_select_menu_button_selected(item: Control) -> void:
	match item.name:
		"GoToLevel":
			get_tree().paused = false
			Save.delete_progress()
			Save.delete_game_save()
			Gamemgr.load_level(int(%SelectMenu/GoToLevel/SpinBox.get_line_edit().text))
		"Back":
			exit()
