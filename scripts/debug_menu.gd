extends MarginContainer

@onready var fps_btn: Button = $VBoxContainer/SelectMenu/FPSCounter
@onready var tps_btn: Button = $VBoxContainer/SelectMenu/TPSCounter
@onready var save_indicator: Button = $VBoxContainer/SelectMenu/SaveIndicator

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_parent().unhide()
		queue_free()
		get_viewport().set_input_as_handled()

func _ready() -> void:
	Utils.set_settings_state(fps_btn, "fps counter", Settings.fps_on)
	Utils.set_settings_state(tps_btn, "physics tps counter", Settings.tps_on)
	Utils.set_settings_state(save_indicator, "save indicator", Settings.save_indicator_on)

func _on_select_menu_button_selected(item: Object) -> void:
	match item.name:
		"FPSCounter":
			Settings.fps_on = fps_btn.button_pressed
			fps_btn.text = "fps counter: on" if Settings.fps_on else "fps counter: off"
		"TPSCounter":
			Settings.tps_on = tps_btn.button_pressed
			tps_btn.text = "physics tps counter: on" if Settings.tps_on else "physics tps counter: off"
		"SaveIndicator":
			Settings.save_indicator_on = save_indicator.button_pressed
			save_indicator.text = "save indicator: on" if Settings.save_indicator_on else "save indicator: off"
		"Back":
			get_parent().unhide()
			queue_free()
