class_name IrisTransition
extends CanvasLayer

@onready var screen := get_viewport().get_visible_rect().size
const TOTAL_LEVELS := 50
const LEVEL_OFFSET := 0

const COLORS: Array[Color] = [Color("172038"), Color("253a5e"), Color("3c5e8b"), Color("4f8fba"), Color("73bed3"), Color("a4dddb"), Color("a53030"), Color("cf573c"), Color("402751"), Color("7a367b"), Color("a23e8c"), Color("a23e8c"), Color("a23e8c"), Color("ebede9") ]

const SHADER_CODE := """
shader_type canvas_item;
uniform vec2 center = vec2(576.0, 324.0);
uniform float radius = 0.0;
uniform float block = 8.0;
uniform vec2 size = vec2(1152.0, 648.0);
uniform vec4 color : source_color = vec4(1.0);

void fragment() {
	vec2 p = UV * size;
	p = (floor(p / block) + 0.5) * block;   // snap to a pixel grid
	if (distance(p, center) > radius) {
		discard;
	}
	COLOR = color;
}
""" # 100% ai bc im too lazy

var _rect: ColorRect
var _mat: ShaderMaterial
var _label: Label
var _color: Color

static func play(from_screen_pos: Vector2, change_level: Callable, tree: SceneTree, expand_time := 0.7, hold_time := 1.0, shrink_time := 0.7) -> void:
	var t := IrisTransition.new()
	tree.root.add_child(t)
	t._run(from_screen_pos, change_level, expand_time, hold_time, shrink_time)

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_color = COLORS.pick_random()
	
	var shader := Shader.new()
	shader.code = SHADER_CODE
	_mat = ShaderMaterial.new()
	_mat.shader = shader
	_mat.set_shader_parameter(&"color", _color)
	_mat.set_shader_parameter(&"size", screen)
	
	_rect = ColorRect.new()
	_rect.size = screen
	_rect.material = _mat
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)
	
	_label = Label.new()
	_label.size = screen
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.theme = load("res://theme.tres")
	_label.add_theme_font_size_override(&"font_size", 48)
	_label.add_theme_color_override(&"font_color", _contrast_color(_color))
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.hide()
	add_child(_label)
	
	_set_radius(0.0)

func _contrast_color(bg: Color) -> Color:
	var luminance := 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b
	return Color.BLACK if luminance > 0.5 else Color.WHITE

func _set_radius(r: float) -> void:
	_mat.set_shader_parameter(&"radius", r)

func _farthest_corner(from: Vector2) -> float:
	var d = 0.0
	for corner in [Vector2.ZERO, Vector2(screen.x, 0), Vector2(0, screen.y), screen]:
		d = maxf(d, from.distance_to(corner))
	return d + 16.0

func _run(from_pos: Vector2, change_level: Callable, expand_time: float, hold_time: float, shrink_time: float) -> void:
	_mat.set_shader_parameter(&"center", from_pos)
	var full := _farthest_corner(from_pos)
	var tween := create_tween()
	tween.tween_method(_set_radius, 4.0, full, expand_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	await tween.finished
	
	change_level.call()
	await get_tree().process_frame
	await get_tree().process_frame
	_label.text = "level %d / %d" % [Gamemgr.level + LEVEL_OFFSET, TOTAL_LEVELS]
	_label.show()
	await get_tree().create_timer(hold_time).timeout
	
	var center := screen / 2.0
	_mat.set_shader_parameter(&"center", center)
	var start_r := _farthest_corner(center)
	tween = create_tween()
	tween.tween_method(_set_radius, start_r, 0.0, shrink_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	queue_free()
 
