extends Area2D

@export var fade_time := 0.3
@export var move_time := 0.8
@export var pull_to_center := true
@export var shrink := true
@export var spin := true
@export var spin_turns := 1.0

var entered: Array = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("players") or body in entered:
		return
	entered.append(body)
	
	var tween := _absorb(body)
	
	if entered.size() >= get_tree().get_nodes_in_group("players").size():
		await tween.finished
		go_to_next_level()
	
func _absorb(body: Node2D) -> Tween:
	body.set_physics_process(false)
	body.velocity = Vector2.ZERO
	body.standing_on = null
	body.get_node("CollisionShape2D").set_deferred("disabled", true)
	
	var target: Vector2 = $CollisionShape2D.global_position
	var visual_center := _visual_center(body)
	var final_pos: Vector2 = body.global_position + (target - visual_center)
	
	var tween := create_tween().set_parallel(true)
	tween.tween_property(body, "modulate:a", 0.0, fade_time).set_delay(move_time - fade_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if pull_to_center:
		tween.tween_property(body, "global_position", final_pos, move_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tween
	
	# unreachable
	#if shrink:
	#	tween.tween_property(body, "scale", Vector2.ZERO, move_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	#if spin:
	#	tween.tween_property(body, "rotation", body.rotation + TAU * spin_turns, move_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _visual_center(body: Node2D) -> Vector2:
	var sprite: Sprite2D = body.get_node("Sprite2D")
	var local_center := sprite.get_rect().get_center()
	return sprite.to_global(local_center)

func go_to_next_level() -> void:
	#print("Both characters have entered portal!")
	Gamemgr.next_level()
	#get_tree().change_scene_to_file("res://scenes/level_2.tscn")
