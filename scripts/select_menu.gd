class_name SelectMenu
extends Control

signal button_selected(item: Button)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		for child in get_children():
			if child is Button and child == get_viewport().gui_get_hovered_control():
				child.grab_focus()

func _ready() -> void:
	var focused = false
	for child in get_children():
		if child is Button:
			(child as Button).pressed.connect(button_selected.emit.bind(child))
			if not focused:
				child.grab_focus()
				focused = true

func _process(_delta: float) -> void:
	pass
