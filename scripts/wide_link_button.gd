extends LinkButton

func _has_point (point: Vector2):
	return Rect2(Vector2(-Utils.button_padding, 0), size + Vector2(2 * Utils.button_padding, 0)).has_point(point)
