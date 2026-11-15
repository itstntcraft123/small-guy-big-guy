extends Node2D

@export var game_menu: PackedScene
var just_exited_game_menu := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and !has_node("CanvasLayer/EscapeScreen"):
		if just_exited_game_menu:
			just_exited_game_menu = false
		else:
			$CanvasLayer.add_child(game_menu.instantiate())
			get_tree().paused = true

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
