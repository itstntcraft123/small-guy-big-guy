@tool
extends Node

enum PresetColors { NONE, GREEN, BLUE, PURPLE }
const PRESET_COLORS_DATA: Dictionary[PresetColors, Color] = {
	PresetColors.NONE: Color.WHITE,
	PresetColors.GREEN: Color(0.422, 1.0, 0.165, 1.0),
	PresetColors.BLUE: Color(0.378, 0.683, 1.0, 1.0),
	PresetColors.PURPLE: Color(0.924, 0.321, 0.937, 1.0)
}
var in_game := false
var button_padding := 40

func get_children_of_type(node: Node, type: Variant) -> Array[Node]:
	var result: Array[Node] = []
	for child in node.get_children():
		if is_instance_of(child, type):
			result.append(child)
	return result

func get_first_child_of_type(node: Node, type: Variant) -> Node:
	for child in node.get_children():
		if is_instance_of(child, type):
			return child
	return

func connect_focus_signal(node: Node, function: Callable) -> void:
	node.focus_entered.connect(function.bind(node, true))
	node.focus_exited.connect(function.bind(node, false))

func set_settings_state(node: Control, string: String, match_state: bool):
	node.text = string + ": on" if match_state else string + ": off"
	node.set_pressed_no_signal(match_state)

func update_from_save(self_node: Node, save_data: Dictionary, var_name: StringName):
	self_node.set(var_name, save_data.get(var_name, self_node.get(var_name)))

func update_multiple_from_save(self_node: Node, save_data: Dictionary, var_array: Array[StringName]):
	for item in var_array:
		update_from_save(self_node, save_data, item)

# Zip helpers
func write_zip(zip: ZIPPacker, path: String, data: PackedByteArray, condition: bool = true) -> bool:
	if !condition:
		return false
	
	var start_result := zip.start_file(path)
	if start_result != OK:
		push_error("ZIPPacker start file ", path, " failed ", start_result)
		return false
	
	var write_result := zip.write_file(data)
	if write_result != OK:
		push_error("ZIPPacker write file ", path, " failed ", start_result)
		return false
	
	var close_result := zip.close_file()
	if close_result != OK:
		push_error("ZIPPacker close file after writing ", path, " failed ", start_result)
		return false
	
	return true

func write_zip_from_file(zip: ZIPPacker, full_path: String, condition: bool = true) -> bool:
	if !condition:
		return false
	
	var bytes := FileAccess.get_file_as_bytes(full_path)
	if bytes.is_empty():
		if FileAccess.get_open_error() != ERR_FILE_NOT_FOUND:
			push_error("FileAccess open file ", full_path, " as bytes empty ", FileAccess.get_open_error())
		return false
	
	write_zip(zip, full_path.split("/")[-1], bytes, condition)
	return true

func configfile_to_dict(config: ConfigFile, section: String) -> Dictionary:
	var data := {}
	for key in config.get_section_keys(section):
		data[key] = config.get_value(section, key)
	return data

func config_path_to_dict(path: String, section: String) -> Dictionary:
	var config = ConfigFile.new()
	var result = config.load(path)
	if result != OK:
		push_error("ConfigFile load ", path, " failed ", result)
		return {}
	return configfile_to_dict(config, section)
