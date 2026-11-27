extends Control

@export var new_backup_scene: PackedScene

func exit() -> void:
	$"../MarginContainer".show()
	$"../%Backups".grab_focus()
	queue_free()

func _on_options_list_button_selected(item: Control) -> void:
	match item.name:
		"Back":
			exit()
		"Create":
			add_child(new_backup_scene.instantiate())
			$MarginContainer.hide()
