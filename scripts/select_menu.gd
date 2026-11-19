class_name SelectMenu
extends Control

signal button_selected(item: Object)
signal button_focus_changed(item: Object, focus: bool)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		for child in get_children():
			if (child is Button or child is LinkButton) and child == get_viewport().gui_get_hovered_control():
				child.grab_focus()

func _ready() -> void:
	var focused = false
	for child in get_children():
		if child is Button or child is LinkButton:
			child.pressed.connect(button_selected.emit.bind(child))
			child.focus_entered.connect(button_focus_changed.emit.bind(child, true))
			child.focus_exited.connect(button_focus_changed.emit.bind(child, false))
			if not focused:
				child.grab_focus()
				focused = true
