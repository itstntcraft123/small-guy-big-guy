extends Node2D

@export var game_menu: PackedScene
var just_exited_game_menu := false
@onready var fps_label := $CanvasLayer/Theme/VBoxContainer/FPS
@onready var tps_label := $CanvasLayer/Theme/VBoxContainer/TPS

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
	if Settings.fps_on:
		fps_label.show()
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	else:
		fps_label.hide()

# TPS counter
var _timer := 0.0
var _ticks := 0

func _physics_process(delta: float) -> void:
	if Settings.tps_on:
		tps_label.show()
		_timer += delta
		_ticks += 1
		if _timer >= 1.0:
			tps_label.text = "TPS: " + str(_ticks)
			_timer = 0.0
			_ticks = 0
	else:
		tps_label.hide()
