class_name Debris
extends RigidBody2D

var color := Color.WHITE
var size := 4.0

func setup(c: Color, s: float, lifetime: float) -> void:
	color = c
	size = s
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(s, s)
	cs.shape = rect
	add_child(cs)
	
	collision_layer = 0
	collision_mask = 0
	set_collision_mask_value(1, true)
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.4
	physics_material_override.friction = 0.6
	
	var tween := create_tween()
	tween.tween_interval(lifetime * 0.6)
	tween.tween_property(self, "modulate:a", 0.0, lifetime * 0.4)
	tween.tween_callback(queue_free)
	

func _draw() -> void:
	draw_rect(Rect2(-size / 2.0, -size / 2.0, size, size), color)
	
