extends Control

@export var new_backup_scene: PackedScene
@export var backup_scene: PackedScene

func exit() -> void:
	$"../MarginContainer".show()
	$"../%Backups".grab_focus()
	queue_free()

func _ready() -> void:
	reload()

func reload() -> void:
	for child in %BackupsList.get_children():
		child.queue_free()
	for backup in Save.list_backups():
		var inst_scene := backup_scene.instantiate()
		inst_scene.get_node(^"%Name").text = backup.get("name", "Backup")
		var date := Time.get_datetime_dict_from_unix_time(backup.get("unix", 0) + Time.get_time_zone_from_system().bias * 60)
		inst_scene.get_node(^"%Date").text = "%s %d, %d at %d:%s %s" % [
			["Jan.", "Feb.", "Mar.", "Apr.", "May", "June", "July", "Aug.", "Sep.", "Oct.", "Nov.", "Dec."][date.month - 1],
			date.day,
			date.year,
			date.hour % 12 if date.hour > 0 else 12,
			str(date.minute).pad_zeros(2),
			"pm" if date.hour > 11 else "am"
		]
		var parameters: Label = inst_scene.get_node(^"%Parameters")
		parameters.text = ""
		if backup.get("config"):
			parameters.text += "Config\n"
		if backup.get("game"):
			parameters.text += "Game Progress\n"
		if backup.get("level"):
			parameters.text += "Level Progress"
		%BackupsList.add_child(inst_scene)

func _on_options_list_button_selected(item: Control) -> void:
	match item.name:
		"Back":
			exit()
		"Create":
			add_child(new_backup_scene.instantiate())
			$MarginContainer.hide()
