extends Area2D

enum TeleporterColor { BLUE, RED, PURPLE, GREEN }

@export var teleporter_color := TeleporterColor.BLUE

var ignored: Array[Node2D] = []

func _ready() -> void:
	$Sprite2D.frame = teleporter_color
	add_to_group(_group_name())
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _group_name() -> String:
	return "teleporter_%d" % teleporter_color

func get_partner() -> Area2D:
	for tp in get_tree().get_nodes_in_group(_group_name()):
		if tp != self:
			return tp
	return null

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("players") or body in ignored:
		return
	var partner := get_partner()
	if partner == null:
		return
	partner.ignored.append(body)
	_teleport.call_deferred(body, partner.global_position)

func _teleport(body: Node2D, target: Vector2) -> void:
	body.global_position = target
	reset_physics_interpolation()
	
func _on_body_exited(body: Node2D) -> void:
	ignored.erase(body)
