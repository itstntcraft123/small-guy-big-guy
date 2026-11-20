extends CanvasLayer

@onready var fps_label := $Theme/VBoxContainer/FPS
@onready var tps_label := $Theme/VBoxContainer/TPS
@onready var save_indicator := $Theme/VBoxContainer/SaveIndicator
@onready var save_timer := $SaveTimer

var just_saved := false

func _process(_delta: float) -> void:
	if Settings.fps_on:
		fps_label.show()
		fps_label.text = "FPS: " + str(int(Engine.get_frames_per_second()))
	else:
		fps_label.hide()
	if just_saved and Settings.save_indicator_on:
		save_indicator.show()
		save_timer.start()
		just_saved = false

# TPS counter
var _timer := 0.0
var _ticks := 0

func _physics_process(delta: float) -> void:
	if Settings.tps_on:
		tps_label.show()
		_timer += delta
		_ticks += 1
		if _timer >= 1.0:
			tps_label.text = "TPS: " + str(_ticks)
			_timer = 0.0
			_ticks = 0
	else:
		tps_label.hide()

func _on_save_timer_timeout() -> void:
	save_indicator.hide()
