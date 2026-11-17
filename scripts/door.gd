@tool
extends StaticBody2D

@export_enum("Green", "Blue", "Purple") var color: int = 0:
	set(value):
		color = value
		_update_sprite()

@export var use_buffer := true
@export var hold_open_time := 1.0
@export var open_delay := 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D

var is_open := false
var hold_timer := 0.0
var delay_timer := 0.0

func _physics_process(delta: float) -> void:
	var powered := false
	for b in get_tree().get_nodes_in_group("buttons"):
		if not ("type" in b and "active" in b):
			continue
		if b.type == color and b.active:
			powered = true
			break
	
	var hold := hold_open_time if use_buffer else 0.0
	var delay := open_delay if use_buffer else 0.0
	
	if powered:
		hold_timer = hold
		if not is_open:
			delay_timer += delta
			if delay_timer >= delay:
				_set_open(true)
	else:
		delay_timer = 0.0
		if is_open:
			hold_timer -= delta
			if hold_timer <= 0.0:
				_set_open(false)

func _set_open(open: bool) -> void:
	is_open = open
	sprite.visible = not open
	shape.set_deferred("disabled", open)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# add_to_group("buttons")
	_update_sprite()
	
func _update_sprite() -> void:
	if not is_node_ready():
		return
	sprite.frame = color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
