extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = 380.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var small_sprite: Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_pressed("small_jump") and is_on_floor():
		velocity.y = -JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("small_move_left", "small_move_right")
	if direction != 0:
		velocity.x = direction * SPEED
		small_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
