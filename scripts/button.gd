@tool
extends Area2D

enum Type { GREEN, BLUE, PURPLE }
# green is for small, blue is for big, purple is for both

@export var type: Type = Type.GREEN
@export var big_weight_threshold: float = 1.5

@export var tex_idle: Texture2D
@export var tex_small: Texture2D
@export var tex_big: Texture2D
@export var tex_pressed: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var strip: CollisionShape2D = $CollisionShape2D
@onready var platform: AnimatableBody2D = $Platform
@onready var platform_shape: CollisionShape2D = $Platform/CollisionShape2D

var active := false
var current_tex: Texture2D = null

var held: Array = []
var grace := 0
const GRACE_FRAMES := 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("buttons")
	sprite.centered = false
	strip.shape = strip.shape.duplicate()
	platform_shape.shape = platform_shape.shape.duplicate()
	platform_shape.position = Vector2.ZERO
	_apply_texture(tex_idle)
	_setup_strip()

func _setup_strip() -> void:
	if tex_idle == null:
		return
	var idle_h := tex_idle.get_height()
	var pressed_h := idle_h
	if tex_pressed != null:
		pressed_h = tex_pressed.get_height()
	
	var top := -idle_h - 1.0
	var bottom := -pressed_h + 2.0
	(strip.shape as RectangleShape2D).size.y = bottom - top
	strip.position.y = (top + bottom) / 2.0

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	var small_on := false
	var big_on := false
	
	var counted: Array = []
	for body in get_tree().get_nodes_in_group("players"):
		if body.standing_on == platform:
			_add_with_riders(body, counted)
			
	if not counted.is_empty():
			held = counted.duplicate()
			grace = GRACE_FRAMES
	elif grace > 0:
			grace -= 1
			counted = held
	else:
		held = []
	
	for body in counted:
		if body.weight >= big_weight_threshold:
			big_on = true
		else:
			small_on = true
	
	var now_active := false
	var tex := tex_idle
	
	match type: 
		Type.GREEN: 
			now_active = small_on or big_on
			tex = tex_pressed if now_active else tex_idle
		Type.BLUE: 
			now_active = big_on
			if now_active:
				tex = tex_pressed
			elif small_on:
				tex = tex_small
		Type.PURPLE: 
			now_active = small_on and big_on
			if now_active:
				tex = tex_pressed
			elif big_on:
				tex = tex_big
			elif small_on:
				tex = tex_small
	_apply_texture(tex if tex != null else tex_idle)
	
	if now_active and not active:
		execute()
	active = now_active
	
func _apply_texture(tex: Texture2D) -> void:
	if tex == null or tex == current_tex:
		return
	current_tex = tex
	sprite.texture = tex
	
	var w := tex.get_width()
	var h := tex.get_height()
	sprite.offset = Vector2(-w / 2.0, -h)
	
	var plat_h: float = (platform_shape.shape as RectangleShape2D).size.y
	platform.position.y = -h + plat_h / 2.0

func _add_with_riders(body: Node, counted: Array) -> void:
	if body in counted:
		return
	counted.append(body)
	for other in get_tree().get_nodes_in_group("players"):
		if other != body and other.standing_on == body:
			_add_with_riders(other, counted)

func execute() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
