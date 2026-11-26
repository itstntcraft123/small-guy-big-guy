extends MarginContainer

func exit() -> void:
	$"../MarginContainer".show()
	$"../%Backups".grab_focus()
	queue_free()

func _on_options_list_button_selected(item: Control) -> void:
	match item.name:
		"Back":
			exit()
