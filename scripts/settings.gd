extends Node

var fps_on := false
var tps_on := false
var save_indicator_on := false
var prev_vsync := DisplayServer.window_get_vsync_mode()
var prev_fullscreen := DisplayServer.window_get_mode()

func _ready() -> void:
	add_to_group("save")
	Save.load_save(true)

func _process(_delta: float) -> void:
	if DisplayServer.window_get_vsync_mode() != prev_vsync:
		Save.save_data()
	prev_vsync = DisplayServer.window_get_vsync_mode()
	if DisplayServer.window_get_mode() != prev_fullscreen:
		Save.save_data()
	prev_fullscreen = DisplayServer.window_get_mode()

func save_dict() -> Dictionary:
	return {
		"fps_on": fps_on,
		"tps_on": tps_on,
		"save_indicator_on": save_indicator_on,
		"vsync": DisplayServer.window_get_vsync_mode(),
		"fullscreen": DisplayServer.window_get_mode()
	}

func load_dict(save_data: Dictionary) -> void:
	fps_on = save_data.get("fps_on", fps_on)
	tps_on = save_data.get("tps_on", tps_on)
	save_indicator_on = save_data.get("save_indicator_on", save_indicator_on)
	DisplayServer.window_set_vsync_mode(save_data.get("vsync", DisplayServer.window_get_vsync_mode()))
	DisplayServer.window_set_mode(save_data.get("fullscreen", DisplayServer.window_get_mode()))
