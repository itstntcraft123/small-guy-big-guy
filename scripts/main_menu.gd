extends Control

@export var options_menu: PackedScene 

func _on_select_menu_button_selected(item: Object) -> void:
	match item.name:
		"Play":
			Gamemgr.load_current_level()
		"Options":
			add_child(options_menu.instantiate())
			$MarginContainer.hide()
		"Quit":
			if OS.has_feature("web"):
				get_tree().change_scene_to_file("res://scenes/quit_screen.tscn")
			else:
				get_tree().quit()

func unhide() -> void:
	$MarginContainer.show()
	$MarginContainer/VBoxContainer/SelectMenu/Options.grab_focus()
