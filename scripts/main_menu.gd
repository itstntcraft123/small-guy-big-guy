extends Control

@export var options_menu: PackedScene 

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _on_select_menu_button_selected(item: Button) -> void:
	match item.name:
		"Play":
			get_tree().change_scene_to_file("res://scenes/game.tscn")
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
