extends Control

@export var debug_options: PackedScene

func _input(event: InputEvent) -> void:
	%ScrollContainer.follow_focus = true
	if event is InputEventMouseMotion:
		%ScrollContainer.follow_focus = false
	
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		get_parent().unhide()
		Save.save_cfg()
		queue_free()

func _ready() -> void:
	Save.load_cfg()
	if OS.has_feature("web"):
		%Vsync.hide()

func _process(_delta: float) -> void:
	Utils.set_settings_state(%Fullscreen, "fullscreen", _is_fullscreen())
	Utils.set_settings_state(%Vsync, "vsync", DisplayServer.window_get_vsync_mode())
	Utils.set_settings_state(%RestartKey, "r to restart", Settings.r_to_restart)
	Utils.set_settings_state(%Touch, "touch controls", Settings.touch_controls)
	%SaveSpeedSpinBox.value = Settings.autosave_speed

func _on_select_menu_button_selected(item: Control) -> void:
	match item.name:
		"Fullscreen":
			if !item.button_pressed:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		"Vsync":
			if !item.button_pressed:
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
			else:
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		"Touch":
			Settings.touch_controls = item.button_pressed
		"RestartKey":
			Settings.r_to_restart = item.button_pressed
		"SaveSpeed":
			Settings.autosave_speed = int(item.get_child(0).value)
		"Debug":
			add_child(debug_options.instantiate())
			$MarginContainer.hide()
		"Back":
			get_parent().unhide()
			Save.save_cfg()
			queue_free()

func _is_fullscreen() -> bool:
	var mode = DisplayServer.window_get_mode()
	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

func unhide() -> void:
	$MarginContainer.show()
	%Debug.grab_focus()
