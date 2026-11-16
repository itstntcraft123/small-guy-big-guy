extends MarginContainer
class_name Settings

@onready var fullscreen_btn: Button = $VBoxContainer/SelectMenu/Fullscreen
@onready var vsync_btn: Button = $VBoxContainer/SelectMenu/Vsync
@onready var fps_btn: Button = $VBoxContainer/SelectMenu/FPSCounter
@onready var tps_btn: Button = $VBoxContainer/SelectMenu/TPSCounter

static var fps_on := false
static var tps_on := false

func _ready() -> void:
	fps_btn.text = "fps counter: on" if fps_on else "fps counter: off"
	fps_btn.set_pressed_no_signal(fps_on)
	tps_btn.text = "physics tps counter: on" if tps_on else "physics tps counter: off"
	tps_btn.set_pressed_no_signal(tps_on)

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
		"FPSCounter":
			fps_on = fps_btn.button_pressed
			fps_btn.text = "fps counter: on" if fps_on else "fps counter: off"
		"TPSCounter":
			tps_on = tps_btn.button_pressed
			tps_btn.text = "physics tps counter: on" if tps_on else "physics tps counter: off"
		"Back":
			get_parent().unhide()
			queue_free()

func _is_fullscreen() -> bool:
	var mode = DisplayServer.window_get_mode()
	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

func _on_select_menu_button_focus_changed(item: Button, focus: bool) -> void:
	if focus:
		item.add_theme_color_override("font_pressed_color", item.get_theme_color("font_hover_pressed_color"))
	else:
		item.remove_theme_color_override("font_pressed_color")
