extends MarginContainer

func exit() -> void:
	$"../MarginContainer".show()
	$"../%Debug".grab_focus()
	get_parent().refresh_visible()
	queue_free()

func _ready() -> void:
	_refresh_settings()

func _refresh_settings() -> void:
	Utils.set_settings_state(%FPSCounter, "fps counter", Settings.fps_on)
	Utils.set_settings_state(%TPSCounter, "physics tps counter", Settings.tps_on)
	Utils.set_settings_state(%SaveIndicator, "save indicator", Settings.save_indicator_on)
	Utils.set_settings_state(%ShowAll, "show all options", Settings.show_all)

func _on_select_menu_button_selected(item: Object) -> void:
	match item.name:
		"FPSCounter":
			Settings.fps_on = item.button_pressed
		"TPSCounter":
			Settings.tps_on = item.button_pressed
		"SaveIndicator":
			Settings.save_indicator_on = item.button_pressed
		"ShowAll":
			Settings.show_all = item.button_pressed
		"Back":
			exit()
	_refresh_settings()
