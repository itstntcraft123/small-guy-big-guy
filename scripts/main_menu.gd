extends Control

@export var options_menu: PackedScene 
@export var title_slide_time := 1.0
@export var button_slide_time := 1.0
@export var button_stagger := 0.3
@export var button_delay := 0.1

func _ready() -> void:
	$Version.text = "v" + ProjectSettings.get_setting("application/config/version", "1.0.1")
	
	await get_tree().process_frame
	_play_intro()

func _play_intro() -> void:
	var title: Control = $MarginContainer/VBoxContainer/Title
	var menu: Control = $MarginContainer/VBoxContainer/SelectMenu
	var buttons: Array[Control] = [
		menu.get_node("Play"),
		menu.get_node("Options"), 
		menu.get_node("Quit"),
	]
	
	for b in buttons:
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.focus_mode = Control.FOCUS_NONE
		
	var title_end := title.position
	title.position.x = get_viewport_rect().size.x
	title.modulate.a = 0.0
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(title, "position:x", title_end.x, title_slide_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(title, "modulate:a", 1.0, title_slide_time * 0.5)
	
	var button_ends: Array[float] = []
	for b in buttons:
		button_ends.append(b.position.y)
		b.position.y = get_viewport_rect().size.y
		b.modulate.a = 0.0
	
	for i in buttons.size():
		var delay := title_slide_time + button_delay + i * button_stagger
		tween.tween_property(buttons[i], "position:y", button_ends[i], button_slide_time).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(buttons[i], "modulate:a", 1.0, button_slide_time * 0.6).set_delay(delay)
	
	await tween.finished
	
	for b in buttons:
		b.mouse_filter = Control.MOUSE_FILTER_STOP
		b.focus_mode = Control.FOCUS_ALL
	buttons[0].grab_focus()



func _on_select_menu_button_selected(item: Control) -> void:
	match item.name:
		"Play":
			Gamemgr.load_current_level()
		"Options":
			add_child(options_menu.instantiate())
			$MarginContainer.hide()
		"Quit":
			if OS.has_feature("web"):
				get_tree().change_scene_to_file("res://scenes/quit_screen.tscn")
			else:
				get_tree().quit()

func unhide() -> void:
	$MarginContainer.show()
	$MarginContainer/VBoxContainer/SelectMenu/Options.grab_focus()
