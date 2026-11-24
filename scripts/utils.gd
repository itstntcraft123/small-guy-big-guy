@tool
extends Node

enum PresetColors { NONE, GREEN, BLUE, PURPLE }
const PRESET_COLORS_DATA: Dictionary[PresetColors, Color] = {
	PresetColors.NONE: Color.WHITE,
	PresetColors.GREEN: Color(0.422, 1.0, 0.165, 1.0),
	PresetColors.BLUE: Color(0.378, 0.683, 1.0, 1.0),
	PresetColors.PURPLE: Color(0.924, 0.321, 0.937, 1.0)
}
var in_game := false

func get_children_of_type(node: Node, type: Variant) -> Array[Node]:
	var result: Array[Node] = []
	for child in node.get_children():
		if is_instance_of(child, type):
			result.append(child)
	return result

func get_first_child_of_type(node: Node, type: Variant) -> Node:
	for child in node.get_children():
		if is_instance_of(child, type):
			return child
	return

func connect_focus_signal(node: Node, function: Callable) -> void:
	node.focus_entered.connect(function.bind(node, true))
	node.focus_exited.connect(function.bind(node, false))

func set_settings_state(node: Control, string: String, match_state: bool):
	node.text = string + ": on" if match_state else string + ": off"
	node.set_pressed_no_signal(match_state)

func update_from_save(self_node: Node, save_data: Dictionary, var_name: StringName):
	self_node.set(var_name, save_data.get(var_name, self_node.get(var_name)))

func update_multiple_from_save(self_node: Node, save_data: Dictionary, var_array: Array[StringName]):
	for item in var_array:
		update_from_save(self_node, save_data, item)
