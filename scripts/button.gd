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

var active := false

func _physics_process(_delta: float) -> void:
	var small_on := false
	var big_on := false
	for body in get_overlapping_bodies():
		if body.is_in_group("players"):
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
	sprite.texture = tex
	
	if now_active and not active:
		execute()
	active = now_active
	
func execute() -> void:
	pass
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
