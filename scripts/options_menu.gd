extends Control

@export var debug_options: PackedScene

@onready var fullscreen_btn: Button = $MarginContainer/VBoxContainer/ScrollContainer/SelectMenu/Fullscreen
@onready var vsync_btn: Button = $MarginContainer/VBoxContainer/ScrollContainer/SelectMenu/Vsync
@onready var restart_btn: Button = $MarginContainer/VBoxContainer/ScrollContainer/SelectMenu/RestartKey
@onready var scroll: ScrollContainer = $MarginContainer/VBoxContainer/ScrollContainer

func _input(event: InputEvent) -> void:
	scroll.follow_focus = true
	if event is InputEventMouseMotion:
		scroll.follow_focus = false
	
	if event.is_action_pressed("ui_cancel"):
		get_parent().unhide()
		Save.save_cfg()
		queue_free()
		get_viewport().set_input_as_handled()

func _ready() -> void:
	Save.load_cfg()

func _process(_delta: float) -> void:
	Utils.set_settings_state(fullscreen_btn, "fullscreen", _is_fullscreen())
	Utils.set_settings_state(vsync_btn, "vsync", DisplayServer.window_get_vsync_mode())
	Utils.set_settings_state(restart_btn, "r to restart", Settings.r_to_restart)
	$MarginContainer/VBoxContainer/ScrollContainer/SelectMenu/SaveSpeed/SpinBox.value = Settings.autosave_speed

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
	$MarginContainer/VBoxContainer/ScrollContainer/SelectMenu/Debug.grab_focus()
