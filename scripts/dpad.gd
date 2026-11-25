extends Control

@export var prefix := "small"

func _ready() -> void:
	$Left.action = prefix + "_left"
	$Up.action = prefix + "_jump"
	$Right.action = prefix + "_right"
