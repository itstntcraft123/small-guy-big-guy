extends AnimatableBody2D

@export var travel := Vector2(200, 0) # how far it moves from start position
@export var duration := 2.0

var origin: Vector2
var t := 0.0

func _ready() -> void:
	sync_to_physics = 2
	origin = position
	add_to_group("save")
	
func _physics_process(delta: float) -> void:
	t += delta
	var weight := 0.5 - 0.5 * cos(PI * t / duration)
	position = origin + travel * weight

func save_dict() -> Dictionary:
	return {"t": t}

func load_dict(data: Dictionary) -> void:
	Utils.update_from_save(self, data, &"t")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
