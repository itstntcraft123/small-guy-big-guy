extends Control

@export var options_menu: PackedScene 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = false
		$"../..".just_exited_game_menu = true
		queue_free()

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _on_select_menu_button_selected(item: Button) -> void:
	match item.name:
		"BackToGame":
			get_tree().paused = false
			queue_free()
		"Options":
			add_child(options_menu.instantiate())
			$MarginContainer.hide()
		"Quit":
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func unhide() -> void:
	$MarginContainer.show()
	$MarginContainer/VBoxContainer/SelectMenu/Options.grab_focus()
