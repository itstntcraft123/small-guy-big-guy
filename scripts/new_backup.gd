extends MarginContainer

func exit() -> void:
	$"../MarginContainer".show()
	$"../%Create".grab_focus()
	get_parent().reload()
	queue_free()

func _ready() -> void:
	%LineEdit.placeholder_text = "Backup on " + Time.get_date_string_from_system() + " at " + Time.get_time_string_from_system()

func _on_data_list_button_selected(item: Control) -> void:
	match item.name:
		"Config":
			Utils.set_settings_state(%DataList/Config, "config", item.button_pressed)
		"Progress":
			Utils.set_settings_state(%DataList/Progress, "game progress", item.button_pressed)
		"LevelData":
			Utils.set_settings_state(%DataList/LevelData, "current level progress", item.button_pressed)

func _on_options_list_button_selected(item: Control) -> void:
	match item.name:
		"Back":
			exit()
		"Create":
			if %DataList/Name/LineEdit.text.is_empty():
				%DataList/Name/LineEdit.text = "Backup on " + Time.get_date_string_from_system() + " at " + Time.get_time_string_from_system()
			Save.create_backup(%DataList/Name/LineEdit.text, %DataList/Config.button_pressed, %DataList/Progress.button_pressed, %DataList/LevelData.button_pressed)
			exit()
