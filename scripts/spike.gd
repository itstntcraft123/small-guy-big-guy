extends Area2D

var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if triggered or not body.is_in_group("players"):
		return
	triggered = true

	get_tree().paused = true
	await get_tree().create_timer(0.3).timeout
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")
