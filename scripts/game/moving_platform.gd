extends AnimatableBody2D

const TILE := 32

@export var texture: Texture2D:
	set(v):
		texture = v
		queue_redraw()
@export var atlas_start := Vector2i(1,3):
	set(v):
		atlas_start = v
		queue_redraw()
@export_range(1,20) var length := 3:
	set(v):
		length = v
		_update_shape()
		queue_redraw()

@export_group("Movement")
@export var travel := Vector2(128, 0) # how far it moves from start position
@export var duration := 2.0

var origin: Vector2
var t := 0.0

func _ready() -> void:
	_update_shape()
	if Engine.is_editor_hint():
		return
	sync_to_physics = true
	origin = position
	add_to_group("save")

func _draw() -> void:
	if texture == null:
		return
	var x := -length * TILE / 2.0
	for i in length:
		var col := atlas_start.x + 1
		if length > 1:
			if i == 0:
				col = atlas_start.x
			elif i == length - 1:
				col = atlas_start.x + 2
		var src := Rect2(col * TILE, atlas_start.y * TILE, TILE, TILE)
		draw_texture_rect_region(texture, Rect2(x + i * TILE, -TILE / 2.0, TILE, TILE), src)
		

func _update_shape() -> void:
	var cs := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if cs == null:
		return
	var rect := RectangleShape2D.new()
	rect.size = Vector2(length * TILE, TILE)
	cs.shape = rect
	

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
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
