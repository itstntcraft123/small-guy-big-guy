extends MarginContainer

@onready var fps_btn: Button = $VBoxContainer/SelectMenu/FPSCounter
@onready var tps_btn: Button = $VBoxContainer/SelectMenu/TPSCounter
@onready var save_indicator: Button = $VBoxContainer/SelectMenu/SaveIndicator

func _ready() -> void:
	fps_btn.text = "fps counter: on" if Settings.fps_on else "fps counter: off"
	fps_btn.set_pressed_no_signal(Settings.fps_on)
	tps_btn.text = "physics tps counter: on" if Settings.tps_on else "physics tps counter: off"
	tps_btn.set_pressed_no_signal(Settings.tps_on)
	save_indicator.text = "save indicator: on" if Settings.save_indicator_on else "save indicator: off"
	save_indicator.set_pressed_no_signal(Settings.save_indicator_on)

func _on_select_menu_button_selected(item: Button) -> void:
	match item.name:
		"FPSCounter":
			Settings.fps_on = fps_btn.button_pressed
			fps_btn.text = "fps counter: on" if Settings.fps_on else "fps counter: off"
		"TPSCounter":
			Settings.tps_on = tps_btn.button_pressed
			tps_btn.text = "physics tps counter: on" if Settings.tps_on else "physics tps counter: off"
		"SaveIndicator":
			Settings.save_indicator_on = save_indicator.button_pressed
			save_indicator.text = "save indicator: on" if Settings.save_indicator_on else "save indicator: off"
		"Back":
			get_parent().unhide()
			queue_free()

func _on_select_menu_button_focus_changed(item: Button, focus: bool) -> void:
	if focus:
		item.add_theme_color_override("font_pressed_color", item.get_theme_color("font_hover_pressed_color"))
	else:
		item.remove_theme_color_override("font_pressed_color")
