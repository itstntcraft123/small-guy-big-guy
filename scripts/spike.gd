extends Area2D

var triggered := false

# Called when the node enters the scene tree for the first time.
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
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
