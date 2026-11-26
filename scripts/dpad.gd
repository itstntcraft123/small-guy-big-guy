extends Control

@export var prefix := "small"

func _process(_delta: float) -> void:
	if not Settings.touch_controls:
		return
	check_input($Left, "_left")
	check_input($Up, "_jump")
	check_input($Right, "_right")

func check_input(node: Node, suffix: String):
	for child: TouchScreenButton in node.get_children():
		if child.is_pressed():
			if Input.is_action_pressed(prefix + suffix):
				return
			Input.action_press(prefix + suffix)
			node.set_meta("just_pressed", true)
			return
	if node.get_meta("just_pressed", false):
		Input.action_release(prefix + suffix)
