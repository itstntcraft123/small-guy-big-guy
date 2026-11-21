class_name SelectMenu
extends Control

signal button_selected(item: Control)
var strip_non_numbers_regex := RegEx.new()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var hovered := get_viewport().gui_get_hovered_control()
		var focused := get_viewport().gui_get_focus_owner()
		for child in get_children():
			if (child is Button or child is LinkButton or child is Label) and child == hovered:
				if child == focused or (focused and child.is_ancestor_of(focused)):
					return
				child.grab_focus()
				return
	
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		var focused := get_viewport().gui_get_focus_owner()
		if focused is LineEdit and focused.get_parent() is SpinBox:
			var children := get_children()
			var diff := -1 if event.is_action_pressed("ui_up") else 1
			var focused_index := -1
			for i in children.size():
				if children[i] == focused.get_parent().get_parent():
					focused_index = i
			var new_node := children[focused_index + diff]
			if focused_index != -1 and new_node is Control and new_node.focus_mode != Control.FOCUS_NONE:
				new_node.grab_focus()
			get_viewport().set_input_as_handled()

func _on_spin_box_line_edit_changed(text: String, spinbox: SpinBox) -> void:
	var lineedit := spinbox.get_line_edit()
	var caret := lineedit.caret_column
	var new_text := strip_non_numbers_regex.sub(text, "", true)
	if text == new_text:
		return
	lineedit.text = new_text
	lineedit.caret_column = caret - 1

func _ready() -> void:
	strip_non_numbers_regex.compile("\\D")
	
	var focused = false
	for child in get_children():
		if child is Button or child is LinkButton:
			child.pressed.connect(button_selected.emit.bind(child))
		if child is Button or child is LinkButton or child is Label:
			child.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			child.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			Utils.connect_focus_signal(child, _focus_changed)
			if not focused:
				child.grab_focus()
				focused = true
		var spinbox := Utils.get_first_child_of_type(child, SpinBox) as SpinBox
		if spinbox:
			Utils.connect_focus_signal(spinbox.get_line_edit(), _focus_changed)
			spinbox.get_line_edit().max_length = 4
			spinbox.get_line_edit().text_changed.connect(_on_spin_box_line_edit_changed.bind(spinbox))

func _focus_changed(item: Control, focus: bool):
	if item is Button and item.toggle_mode:
		if focus:
			item.add_theme_color_override("font_pressed_color", item.get_theme_color("font_hover_pressed_color"))
		else:
			item.remove_theme_color_override("font_pressed_color")
	
	if item is LinkButton:
		item.underline = LinkButton.UNDERLINE_MODE_ALWAYS if focus else LinkButton.UNDERLINE_MODE_NEVER
	
	var spinbox := Utils.get_first_child_of_type(item, SpinBox) as SpinBox
	if spinbox and focus:
		var lineedit := spinbox.get_line_edit()
		lineedit.grab_focus()
		lineedit.edit()
		lineedit.select()
	
	if item is LineEdit:
		var button: Control = item.get_parent().get_parent()
		if focus:
			button.add_theme_color_override("font_color", button.get_theme_color("font_focus_color", "Button"))
		else:
			button.remove_theme_color_override("font_color")
