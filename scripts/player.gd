extends CharacterBody2D
class_name Player

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
var standing_on: Node = null

@onready var small_sprite: Sprite2D = $Sprite2D
@onready var screen_size := get_viewport_rect().size

var top_rider: Player = null
var pushed: Player = null

func _ready() -> void:
	add_to_group("players")
	small_sprite.scale = Vector2(size_scale, size_scale)
	$CollisionShape2D.scale = Vector2(size_scale, size_scale)
	floor_snap_length = 6.0

func _physics_process(delta: float) -> void:
	var frame := Engine.get_physics_frames()
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# if guy stands on guy, then "presed down"
	var below := KinematicCollision2D.new()
	if test_move(global_transform, Vector2(0,2), below) and below.get_normal().y < -0.7:
		var under = below.get_collider()
		if under is Player and weight > under.weight:
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
			if other is Player:
				if weight > other.weight and other.input_dir == 0:
					var blocked: KinematicCollision2D = other.move_and_collide(motion)
					var distance := motion if blocked == null else blocked.get_travel()
					velocity.x = distance.x / delta
					pushed = other
					add_collision_exception_with(other)
	
	# small guy on big guy
	var rider: Player = null
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
	
	standing_on = null
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_normal().y < -0.7:
			standing_on = c.get_collider()
			break
	
	if top_rider:
		remove_collision_exception_with(top_rider)
		top_rider = null
	
	if pushed:
		remove_collision_exception_with(pushed)
		pushed = null
	
	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		var other := col.get_collider()
		if other in get_tree().get_nodes_in_group("players") and col.get_normal().y < -0.7:
			other.top_rider = self
			other.add_collision_exception_with(self)
	
	if rider:
		remove_collision_exception_with(rider)
	
	if position.y > 1000:
		Save.delete_game_save()
		get_tree().paused = false
		Gamemgr.load_current_level()

func save_dict() -> Dictionary:
	return {
		"position": global_position,
		"velocity": velocity,
		"facing": small_sprite.flip_h
	}

func load_dict(save_data: Dictionary) -> void:
	global_position = save_data.get("position", global_position)
	velocity = save_data.get("velocity", velocity)
	small_sprite.flip_h = save_data.get("facing", small_sprite.flip_h)
