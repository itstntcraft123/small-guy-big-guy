@tool
extends StaticBody2D

@export_enum("Green", "Blue", "Purple") var color: int = 0:
	set(value):
		color = value
		_update_sprite()

@export var use_buffer := true
@export var hold_open_time := 1.0
@export var open_delay := 0.0
@export var flash_time := 0.4 # 0 = no flash
var opening := false
var opening_timer := 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D

var is_open := false
var hold_timer := 0.0
var delay_timer := 0.0

func _ready() -> void:
	# add_to_group("buttons")
	_update_sprite()

func _update_sprite() -> void:
	if not is_node_ready():
		return
	sprite.frame = color

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var powered := false
	for b in get_tree().get_nodes_in_group("buttons"):
		if not ("type" in b and "active" in b):
			continue
		if b.type == color and b.active:
			powered = true
			break
	
	var hold := hold_open_time if use_buffer else 0.0
	var delay := open_delay if use_buffer else 0.0
	var flash := flash_time if use_buffer else 0.0
	
	var flashing := false
	var remaining := 0.0
	
	if opening:
		opening_timer -= delta
		if opening_timer <= 0.0:
			opening = false
			hold_timer = hold + flash
			_set_open(true)
		else:
			flashing = true
			remaining = opening_timer
	elif powered:
		hold_timer = hold + flash
		if not is_open:
			delay_timer += delta
			if delay_timer >= delay:
				delay_timer = 0.0
				if flash > 0.0:
					opening = true
					opening_timer = flash
					shape.set_deferred("disabled", true)
					flashing = true
					remaining = flash
				else:
					_set_open(true)
	else:
		delay_timer = 0.0
		if is_open:
			hold_timer -= delta
			if hold_timer <= 0.0:
				_set_open(false)
			elif hold_timer <= flash:
				flashing = true
				remaining = hold_timer
				
	_show_state(flashing, remaining, flash)


func _show_state(flashing: bool, remaining: float, flash: float) -> void:
	var show := not is_open
	if flashing:
		var seg := mini(int(remaining / (flash / 4.0)), 3)
		if seg % 2 == 1:
			show = not show
	sprite.visible = show

func _set_open(open: bool) -> void:
	is_open = open
	shape.set_deferred("disabled", open)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
