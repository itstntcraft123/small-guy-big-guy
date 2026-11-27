class_name IrisTransition
extends CanvasLayer

const SCREEN := Vector2(1152, 648)
const SHADER_CODE := """
shader_type canvas_item;
uniform vec2 center = vec2(576.0, 324.0);
uniform float radius = 0.0;
uniform float block = 8.0;
uniform vec2 size = vec2(1152.0, 648.0);
uniform vec4 color : source_color = vec4(0.09, 0.13, 0.22, 1.0);

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

static func play(from_screen_pos: Vector2, change_level: Callable, tree: SceneTree, expand_time := 0.7, hold_time := 1.0, shrink_time := 0.7) -> void:
	var t := IrisTransition.new()
	tree.root.add_child(t)
	t._run(from_screen_pos, change_level, expand_time, hold_time, shrink_time)

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	var shader := Shader.new()
	shader.code = SHADER_CODE
	_mat = ShaderMaterial.new()
	_mat.shader = shader
	_rect= ColorRect.new()
	_rect.size = SCREEN
	_rect.material = _mat
	add_child(_rect)
	_set_radius(0.0)

func _set_radius(r: float) -> void:
	_mat.set_shader_parameter("radius", r)

func _farthest_corner(from: Vector2) -> float:
	var d = 0.0
	for corner in [Vector2.ZERO, Vector2(SCREEN.x, 0), Vector2(0, SCREEN.y),SCREEN]:
		d = maxf(d, from.distance_to(corner))
	return d + 16.0

func _run(from_pos: Vector2, change_level: Callable, expand_time: float, hold_time: float, shrink_time: float) -> void:
	_mat.set_shader_parameter("center", from_pos)
	var full := _farthest_corner(from_pos)
	var tween := create_tween()
	tween.tween_method(_set_radius, 4.0, full, expand_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	await tween.finished
	
	change_level.call()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(hold_time).timeout
	
	var center := SCREEN / 2.0
	_mat.set_shader_parameter("center", center)
	var start_r := _farthest_corner(center)
	tween = create_tween()
	tween.tween_method(_set_radius, start_r, 0.0, shrink_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	queue_free()
 
