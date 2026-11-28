extends Control

@export var debug_options: PackedScene
@export var backups: PackedScene
@export var dev_cheats: PackedScene

func _input(event: InputEvent) -> void:
	%ScrollContainer.follow_focus = true
	if event is InputEventMouseMotion:
		%ScrollContainer.follow_focus = false

func exit() -> void:
	Save.save_cfg()
	get_parent().unhide()
	queue_free()

func _ready() -> void:
	Save.load_cfg()
	refresh_visible()
	_refresh_settings()
	if OS.is_debug_build():
		%Cheats.show()

func _refresh_settings() -> void:
	Utils.set_settings_state(%RestartKey, "r to restart", Settings.r_to_restart)
	Utils.set_settings_state(%Touch, "touch controls", Settings.touch_controls)
	Utils.set_settings_state(%SaveInLevel, "save in level", Settings.save_in_level)
	%SaveSpeedSpinBox.value = Settings.autosave_speed

func refresh_visible() -> void:
	if Settings.show_all:
		%Vsync.show()
		%Fullscreen.show()
	else:
		if OS.has_feature("web"):
			%Vsync.hide() # browsers force vsync
		if OS.has_feature("web_ios") or OS.has_feature("web_android") or OS.has_feature("mobile"):
			%Fullscreen.hide() # mobile has no fullscreen

func _process(_delta: float) -> void:
	Utils.set_settings_state(%Fullscreen, "fullscreen", _is_fullscreen())
	Utils.set_settings_state(%Vsync, "vsync", DisplayServer.window_get_vsync_mode())

func _on_select_menu_button_selected(item: Control) -> void:
	match item.name:
		"Cheats":
			if OS.is_debug_build():
				add_child(dev_cheats.instantiate())
				$MarginContainer.hide()
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
		"SaveInLevel":
			Settings.save_in_level = item.button_pressed
		"SaveSpeed":
			Settings.autosave_speed = int(item.get_child(0).value)
		"Debug":
			add_child(debug_options.instantiate())
			$MarginContainer.hide()
		"Backups":
			add_child(backups.instantiate())
			$MarginContainer.hide()
		"Back":
			exit()
	_refresh_settings()

func _is_fullscreen() -> bool:
	var mode = DisplayServer.window_get_mode()
	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
