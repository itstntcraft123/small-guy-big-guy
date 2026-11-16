extends Camera2D

@export var zoom_smoothing_enabled := true
@export var margin := Vector2(500, 500)
@export var zoom_smooth_speed := 3.0
@export var min_zoom := 0.5
@export var max_zoom := 10.0

func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("players")
	var rect := Rect2(players[0].global_position, Vector2.ZERO)
	for player: Player in players:
		rect = rect.expand(player.global_position)
	global_position = rect.get_center()
	var viewport := get_viewport_rect().size
	var zoom_amt = clampf(minf(viewport.x / (rect.size.x + margin.x), viewport.y / (rect.size.y + margin.y)), min_zoom, max_zoom)
	if zoom_smoothing_enabled:
		zoom = lerp(zoom, Vector2(zoom_amt, zoom_amt), zoom_smooth_speed * delta)
	else:
		zoom = Vector2(zoom_amt, zoom_amt)

func save_dict() -> Dictionary:
	return {
		"position": global_position,
		"zoom": zoom
	}

func load_dict(save_data: Dictionary) -> void:
	var settings := [position_smoothing_enabled, zoom_smoothing_enabled]
	
	# temp disable smoothing
	zoom_smoothing_enabled = false
	position_smoothing_enabled = false
	
	# set position from save data
	global_position = save_data["position"]
	zoom = save_data["zoom"]
	
	# stop game from processing to prevent frame of camera at wrong position 
	get_parent().process_mode = Node.PROCESS_MODE_DISABLED
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# wait until camera updates to new position
	await get_tree().process_frame
	
	# start game again after camera updates position
	get_parent().process_mode = Node.PROCESS_MODE_INHERIT
	process_mode = Node.PROCESS_MODE_INHERIT
	position_smoothing_enabled = settings[0]
	zoom_smoothing_enabled = settings[1]
