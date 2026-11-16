extends MarginContainer

@onready var fps_btn: Button = $VBoxContainer/SelectMenu/FPSCounter
@onready var tps_btn: Button = $VBoxContainer/SelectMenu/TPSCounter

func _ready() -> void:
	fps_btn.text = "fps counter: on" if Settings.fps_on else "fps counter: off"
	fps_btn.set_pressed_no_signal(Settings.fps_on)
	tps_btn.text = "physics tps counter: on" if Settings.tps_on else "physics tps counter: off"
	tps_btn.set_pressed_no_signal(Settings.tps_on)

func _process(_delta: float) -> void:
	pass

func _on_select_menu_button_selected(item: Button) -> void:
	match item.name:
		"FPSCounter":
			Settings.fps_on = fps_btn.button_pressed
			fps_btn.text = "fps counter: on" if Settings.fps_on else "fps counter: off"
		"TPSCounter":
			Settings.tps_on = tps_btn.button_pressed
			tps_btn.text = "physics tps counter: on" if Settings.tps_on else "physics tps counter: off"
		"Back":
			get_parent().unhide()
			queue_free()

func _on_select_menu_button_focus_changed(item: Button, focus: bool) -> void:
	if focus:
		item.add_theme_color_override("font_pressed_color", item.get_theme_color("font_hover_pressed_color"))
	else:
		item.remove_theme_color_override("font_pressed_color")
