extends Camera2D

@export var margin := Vector2(500, 500)
@export var zoom_smooth_speed := 3.0
@export var min_zoom := 0.5
@export var max_zoom := 10.0

func _physics_process(delta: float) -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("players")
	var rect := Rect2(players[0].global_position, Vector2.ZERO)
	for player: Player in players:
		rect = rect.expand(player.global_position)
	global_position = rect.get_center()
	var viewport := get_viewport_rect().size
	var zoom_amt = clampf(minf(viewport.x / (rect.size.x + margin.x), viewport.y / (rect.size.y + margin.y)), min_zoom, max_zoom)
	zoom = lerp(zoom, Vector2(zoom_amt, zoom_amt), zoom_smooth_speed * delta)
