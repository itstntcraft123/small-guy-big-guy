extends MarginContainer

@onready var fullscreen_btn: Button = $VBoxContainer/SelectMenu/Fullscreen

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	fullscreen_btn.text = "Fullscreen: on" if _is_fullscreen() else "Fullscreen: off"
	fullscreen_btn.set_pressed_no_signal(_is_fullscreen())

func _on_select_menu_button_selected(item: Button) -> void:
	match item.name:
		"Fullscreen":
			if !fullscreen_btn.button_pressed:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		"GoBack":
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_fullscreen_focus_entered() -> void:
	$VBoxContainer/SelectMenu/Fullscreen.add_theme_color_override("font_pressed_color", $VBoxContainer/SelectMenu/Fullscreen.get_theme_color("font_hover_pressed_color"))

func _on_fullscreen_focus_exited() -> void:
	$VBoxContainer/SelectMenu/Fullscreen.remove_theme_color_override("font_pressed_color")

func _is_fullscreen() -> bool:
	var mode = DisplayServer.window_get_mode()
	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
