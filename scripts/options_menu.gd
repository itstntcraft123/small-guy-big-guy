extends Control

@export var debug_options: PackedScene

@onready var fullscreen_btn: Button = $MarginContainer/VBoxContainer/SelectMenu/Fullscreen
@onready var vsync_btn: Button = $MarginContainer/VBoxContainer/SelectMenu/Vsync

func _ready() -> void:
	Save.load_save(true)

func _process(_delta: float) -> void:
	fullscreen_btn.text = "fullscreen: on" if _is_fullscreen() else "fullscreen: off"
	fullscreen_btn.set_pressed_no_signal(_is_fullscreen())
	vsync_btn.text = "vsync: on" if DisplayServer.window_get_vsync_mode() else "vsync: off"
	vsync_btn.set_pressed_no_signal(DisplayServer.window_get_vsync_mode())

func _on_select_menu_button_selected(item: Button) -> void:
	match item.name:
		"Fullscreen":
			if !fullscreen_btn.button_pressed:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		"Vsync":
			if !vsync_btn.button_pressed:
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
			else:
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		"Debug":
			add_child(debug_options.instantiate())
			$MarginContainer.hide()
		"Back":
			get_parent().unhide()
			Save.save_data()
			queue_free()

func _is_fullscreen() -> bool:
	var mode = DisplayServer.window_get_mode()
	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

func _on_select_menu_button_focus_changed(item: Button, focus: bool) -> void:
	if item.toggle_mode:
		if focus:
			item.add_theme_color_override("font_pressed_color", item.get_theme_color("font_hover_pressed_color"))
		else:
			item.remove_theme_color_override("font_pressed_color")

func unhide() -> void:
	$MarginContainer.show()
	$MarginContainer/VBoxContainer/SelectMenu/Debug.grab_focus()
