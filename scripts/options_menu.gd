extends MarginContainer

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	$VBoxContainer/SelectMenu/Fullscreen.text = "Fullscreen: on" if DisplayServer.window_get_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) else "Fullscreen: off"

func _on_select_menu_button_selected(item: Button) -> void:
	match item.name:
		"Fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			item.button_pressed = DisplayServer.window_get_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		"GoBack":
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_fullscreen_focus_entered() -> void:
	$VBoxContainer/SelectMenu/Fullscreen.add_theme_color_override("font_pressed_color", $VBoxContainer/SelectMenu/Fullscreen.get_theme_color("font_hover_pressed_color"))

func _on_fullscreen_focus_exited() -> void:
	$VBoxContainer/SelectMenu/Fullscreen.remove_theme_color_override("font_pressed_color")
