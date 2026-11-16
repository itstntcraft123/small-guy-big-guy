extends Node

static var fps_on := false
static var tps_on := false
static var save_indicator_on := false

func _ready() -> void:
	add_to_group("save")
	Save.load_save(true)

func save_dict() -> Dictionary:
	return {
		"fps_on": fps_on,
		"tps_on": tps_on,
		"save_indicator_on": save_indicator_on
	}

func load_dict(save_data: Dictionary) -> void:
	fps_on = save_data.get("fps_on", fps_on)
	print(fps_on)
	tps_on = save_data.get("tps_on", tps_on)
	save_indicator_on = save_data.get("save_indicator_on", save_indicator_on)
