extends Node

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
