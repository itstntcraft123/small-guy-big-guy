extends Camera2D

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var vector := Vector2.ZERO
	var players = get_tree().get_nodes_in_group("players")
	for player: Player in players:
		vector += player.global_position
	global_position = vector / players.size()
