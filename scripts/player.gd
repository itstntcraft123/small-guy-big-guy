extends CharacterBody2D

@export var move_left_action: String = "small_left"
@export var move_right_action: String = "small_right"
@export var jump_action: String = "small_jump"

@export var speed: float = 200.0
@export var jump_velocity: float = -380.0

@export var size_scale: float = 1.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var small_sprite: Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed(jump_action) and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis(move_left_action, move_right_action)
	if direction != 0:
		velocity.x = direction * speed
		small_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


func _ready() -> void:
	small_sprite.scale = Vector2(size_scale, size_scale)
	$CollisionShape2D.scale = Vector2(size_scale, size_scale)
