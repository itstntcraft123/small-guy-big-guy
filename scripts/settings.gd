extends Node

var fps_on := false
var tps_on := false
var r_to_restart := false
var save_indicator_on := false
var prev_vsync := DisplayServer.window_get_vsync_mode()
var prev_fullscreen := DisplayServer.window_get_mode()
var autosave_speed := 5

func _ready() -> void:
	Save.load_cfg()

func _process(_delta: float) -> void:
	if DisplayServer.window_get_vsync_mode() != prev_vsync:
		Save.save_cfg()
	prev_vsync = DisplayServer.window_get_vsync_mode()
	if DisplayServer.window_get_mode() != prev_fullscreen:
		Save.save_cfg()
	prev_fullscreen = DisplayServer.window_get_mode()

func save_dict() -> Dictionary:
	return {
		"fps_on": fps_on,
		"tps_on": tps_on,
		"r_to_restart": r_to_restart,
		"save_indicator_on": save_indicator_on,
		"autosave_speed": autosave_speed,
		"vsync": DisplayServer.window_get_vsync_mode(),
		"fullscreen": DisplayServer.window_get_mode()
	}

func load_dict(save_data: Dictionary) -> void:
	Utils.update_multiple_from_save(self, save_data,
		[&"save_indicator_on", &"autosave_speed", &"r_to_restart", &"fps_on", &"tps_on"]
	)
	DisplayServer.window_set_vsync_mode(save_data.get("vsync", DisplayServer.window_get_vsync_mode()))
	DisplayServer.window_set_mode(save_data.get("fullscreen", DisplayServer.window_get_mode()))
