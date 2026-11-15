extends CharacterBody2D

@export var move_left_action: String = "small_left"
@export var move_right_action: String = "small_right"
@export var jump_action: String = "small_jump"

@export var speed: float = 200.0
@export var jump_velocity: float = -380.0
@export var size_scale: float = 1.0
@export var weight: float = 1.0 # small guy 1, big guy 2

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var input_dir: float = 0.0
var pressed_frame: int = -100

@onready var small_sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("players")
	small_sprite.scale = Vector2(size_scale, size_scale)
	$CollisionShape2D.scale = Vector2(size_scale, size_scale)

func _physics_process(delta: float) -> void:
	var frame := Engine.get_physics_frames()
	
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# if guy stands on guy, then "presed down"
	var below := KinematicCollision2D.new()
	if test_move(global_transform, Vector2(0,2), below) and below.get_normal().y < -0.7:
		var under = below.get_collider()
		if under is CharacterBody2D and "weight" in under and weight > under.weight:
			under.pressed_frame = frame
	
	# Handle jump.
	var weight_down := frame - pressed_frame <= 2
	# change to Input.is_action_just_pressed if you want to punish holding down jump (harder to do momentum conserve)
	if Input.is_action_pressed(jump_action) and is_on_floor() and not weight_down:
		velocity.y = jump_velocity

	# Horizontal movement
	input_dir = Input.get_axis(move_left_action, move_right_action)
	if input_dir != 0:
		velocity.x = input_dir * speed
		small_sprite.flip_h = input_dir < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	if input_dir != 0:
		var side := KinematicCollision2D.new()
		var motion := Vector2(velocity.x * delta, 0)
		if test_move(global_transform, motion, side) and absf(side.get_normal().x) > 0.7:
			var other = side.get_collider()
			if other is CharacterBody2D and "weight" in other:
				if weight > other.weight and other.input_dir == 00:
					other.move_and_collide(motion)
	
	# small guy on big guy
	var rider: CharacterBody2D = null
	if velocity.y < 0:
		for other in get_tree().get_nodes_in_group("players"):
			if other == self or other.weight >= weight:
				continue
			var col := KinematicCollision2D.new()
			var standing_on_me: bool = other.test_move(other.global_transform, Vector2(0, 2), col) and col.get_collider() == self and col.get_normal().y < -0.7
			if standing_on_me:
				var lift := Vector2(0, velocity.y * delta)
				if other.move_and_collide(lift) == null:
					rider = other
					add_collision_exception_with(rider)
				break
	
	move_and_slide()
	
	if rider:
		remove_collision_exception_with(rider)
