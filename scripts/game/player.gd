extends CharacterBody2D
class_name Player

@export var move_left_action: String = "small_left"
@export var move_right_action: String = "small_right"
@export var jump_action: String = "small_jump"

@export var speed: float = 200.0
@export var jump_velocity: float = -380.0
@export var size_scale: float = 1.0
@export var weight: float = 1.0 # small guy 1, big guy 2

@export_group("Death")
@export var freeze_time := 0.0
@export var respawn_delay := 1.0
@export var debris_count := 24
@export var debris_colors: Array[Color] = [Color("172038"), Color("253a5e"), Color("3c5e8b"), Color("4f8fba")]
@export var debris_speed := Vector2(150, 400)

var dying := false

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var input_dir: float = 0.0
var pressed_frame: int = -100
var standing_on: Node = null
var top_rider: Player = null
var pushed: Player = null

@onready var small_sprite: Sprite2D = $Sprite2D
@onready var screen_size := get_viewport_rect().size
@onready var original_pos := global_position
@onready var shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("players")
	small_sprite.scale = Vector2(size_scale, size_scale)
	shape.scale = Vector2(size_scale, size_scale)
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
	
	if test_move(global_transform, Vector2(input_dir, 0)) and !test_move(global_transform.translated(Vector2(0, -0.5)), Vector2(input_dir, 0)):
		move_and_collide(Vector2(0, -0.5))
	
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
		
		if other is Player and col.get_normal().y < -0.7:
			other.top_rider = self
			other.add_collision_exception_with(self)
		
		if other is Door and col.get_depth() > 1:
			position += find_player_spawn()
	
	if rider:
		remove_collision_exception_with(rider)
	
	if global_position.y > 1000:
		die()

func find_player_spawn() -> Vector2:
	var space := get_world_2d().direct_space_state
	var probe := RectangleShape2D.new()
	probe.size = shape.shape.size * shape.scale
	
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = probe
	query.collide_with_areas = true
	query.exclude = [get_rid()]
	
	var offset := Vector2(0, 0)
	
	while offset.x < 128:
		query.transform = Transform2D(0.0, global_position + offset)
		if space.intersect_shape(query, 1).is_empty():
			return offset
		
		query.transform = Transform2D(0.0, global_position - offset)
		if space.intersect_shape(query, 1).is_empty():
			return -offset
		
		offset.x += 1
	
	return Vector2.ZERO

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

func die() -> void:
	if dying:
		return
	dying = true
	
	set_physics_process(false)
	velocity = Vector2.ZERO
	standing_on = null
	_clear_exceptions()
	shape.set_deferred("disabled", true)
	await get_tree().create_timer(freeze_time).timeout
	
	small_sprite.hide()
	_explode()
	await get_tree().create_timer(respawn_delay).timeout
	
	_clear_exceptions()
	global_position = original_pos
	velocity = Vector2.ZERO
	small_sprite.show()
	shape.set_deferred("disabled", false)
	set_physics_process(true)
	Save.save_game()
	
	await get_tree().create_timer(0.3).timeout
	dying = false

func _explode() -> void:
	var parent := get_parent()
	for i in debris_count:
		var d := Debris.new()
		parent.add_child(d)
		d.global_position = global_position + Vector2(randf_range(-6, 6), randf_range(-6, 6)) * size_scale
		d.setup(debris_colors.pick_random(), randf_range(3.0, 6.0) * size_scale, 2.5)
		d.linear_velocity = Vector2.from_angle(randf() * TAU) * randf_range(debris_speed.x, debris_speed.y)
		d.angular_velocity - randf_range(-10.0, 10.0)

func _clear_exceptions() -> void:
	for body in get_collision_exceptions():
		remove_collision_exception_with(body)
	for other in get_tree().get_nodes_in_group("players"):
		if other != self:
			other.remove_collision_exception_with(self)
	top_rider = null
	pushed = null
