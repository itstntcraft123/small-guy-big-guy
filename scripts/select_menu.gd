class_name SelectMenu
extends Control

signal button_selected(item: Button)

func _ready() -> void:
	for child in get_children():
		if child is Button:
			(child as Button).pressed.connect(button_selected.emit.bind(child))

func _process(_delta: float) -> void:
	pass
