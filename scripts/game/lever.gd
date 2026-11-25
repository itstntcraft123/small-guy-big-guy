@tool
extends StaticBody2D

signal toggled(is_on: bool)

@export var color: Color = Color.WHITE:
	set(value):
		color = value
		if is_node_ready():
			$Sprite2D.modulate = color
@export var inverted := false # if true contros antidoors
@export var undoable := false # can you flip it back off?
@export var flip_time := 0.12 # how long middle frame shows

@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_area: Area2D = $InteractArea

var active := false
var flipping := false
var players_in_range: Array[Node2D] = []

func _ready() -> void:
	sprite.modulate = color
	_apply_frame()
	add_to_group("buttons")
	add_to_group("save")
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)
	

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players") and body not in players_in_range:
		players_in_range.append(body)

func _on_body_exited(body: Node2D) -> void:
	players_in_range.erase(body)

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or flipping or players_in_range.is_empty():
		return
	if event.is_action_pressed("interact"):
		if active and not undoable:
			return
		_flip(not active)

func _flip(to_on: bool) -> void:
	flipping = true
	sprite.frame = 1
	await get_tree().create_timer(flip_time).timeout
	active = to_on
	_apply_frame()
	flipping = false
	toggled.emit(active)

func _apply_frame() -> void:
	sprite.frame = 2 if active else 0
	
func save_dict() -> Dictionary:
	return {"active": active}

func load_dict(data: Dictionary) -> void:
	Utils.update_from_save(self, data, &"active")
	_apply_frame()
