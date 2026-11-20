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
	fullscreen_btn.text = "fullscreen: on" if _is_fullscreen() else "fullscreen: off"
	fullscreen_btn.set_pressed_no_signal(_is_fullscreen())
	vsync_btn.text = "vsync: on" if DisplayServer.window_get_vsync_mode() else "vsync: off"
	vsync_btn.set_pressed_no_signal(DisplayServer.window_get_vsync_mode())
	restart_btn.text = "r to restart: on" if Settings.r_to_restart else "r to restart: off"
	restart_btn.set_pressed_no_signal(Settings.r_to_restart)

func _on_select_menu_button_selected(item: Object) -> void:
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
		"RestartKey":
			Settings.r_to_restart = restart_btn.button_pressed
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

func _on_select_menu_button_focus_changed(item: Object, focus: bool) -> void:
	if item.toggle_mode:
		if focus:
			item.add_theme_color_override("font_pressed_color", item.get_theme_color("font_hover_pressed_color"))
		else:
			item.remove_theme_color_override("font_pressed_color")
	if item is LinkButton:
		item.underline = LinkButton.UNDERLINE_MODE_ALWAYS if focus else LinkButton.UNDERLINE_MODE_NEVER

func unhide() -> void:
	$MarginContainer.show()
	$MarginContainer/VBoxContainer/ScrollContainer/SelectMenu/Debug.grab_focus()
