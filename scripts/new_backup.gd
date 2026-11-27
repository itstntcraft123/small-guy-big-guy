extends MarginContainer

func exit() -> void:
	$"../MarginContainer".show()
	$"../%Create".grab_focus()
	queue_free()

func _ready() -> void:
	%LineEdit.placeholder_text = "Backup on " + Time.get_date_string_from_system() + " at " + Time.get_time_string_from_system()

func _on_options_list_button_selected(item: Control) -> void:
	match item.name:
		"Back":
			exit()
