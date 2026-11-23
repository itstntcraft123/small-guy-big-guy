@tool
extends StaticBody2D
class_name Door

@export var color: Color = Color.WHITE:
	set(value):
		color = value
		_update_sprite()

@export var inverted := false:
	set(value):
		inverted = value
		_update_sprite()
@export var use_buffer := true
@export var hold_open_time := 1.0
@export var open_delay := 0.0
@export var flash_time := 0.4 # 0 = no flash
var opening := false
var opening_timer := 0.0

# antidoor logic
enum Inv { GONE, APPEARING, SOLID, VANISHING}
var inv_state := Inv.GONE
var inv_timer := 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D

var is_open := false
var hold_timer := 0.0
var delay_timer := 0.0

func _ready() -> void:
	if inverted and not Engine.is_editor_hint():
		_set_open(true)
	_update_sprite()

func _update_sprite() -> void:
	if not is_node_ready():
		return
	sprite.visible = true
	sprite.modulate = color
	sprite.frame = _frame_for(not is_open)

func _frame_for(solid: bool) -> int:
	if not inverted: 
		return 0
	return 1 if solid else 2

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var powered := false
	for b in get_tree().get_nodes_in_group("buttons"):
		if not ("color" in b and "active" in b and "inverted" in b):
			continue
		if b.inverted != inverted:
			continue
		if not b.color.is_equal_approx(color):
			continue
		if b.active:
			powered = true
			break
	
	if inverted:
		_inverted_step(delta, powered)
		return
	
	var hold := hold_open_time if use_buffer else 0.0
	var delay := open_delay if use_buffer else 0.0
	var flash := flash_time if use_buffer else 0.0
	
	var flashing := false
	var remaining := 0.0
	
	if opening:
		opening_timer -= delta
		if opening_timer <= 0.0:
			opening = false
			hold_timer = hold + flash
			_set_open(true)
		else:
			flashing = true
			remaining = opening_timer
	elif powered:
		hold_timer = hold + flash
		if not is_open:
			delay_timer += delta
			if delay_timer >= delay:
				delay_timer = 0.0
				if flash > 0.0:
					opening = true
					opening_timer = flash
					shape.set_deferred("disabled", true)
					flashing = true
					remaining = flash
				else:
					_set_open(true)
	else:
		delay_timer = 0.0
		if is_open:
			hold_timer -= delta
			if hold_timer <= 0.0:
				_set_open(false)
			elif hold_timer <= flash:
				flashing = true
				remaining = hold_timer
				
	_show_state(flashing, remaining, flash)


func _show_state(flashing: bool, remaining: float, flash: float) -> void:
	var solid := not is_open
	if flashing:
		var seg := mini(int(remaining / (flash / 4.0)), 3)
		if seg % 2 == 1:
			solid = not solid
	
	if inverted:
		sprite.visible = true
		sprite.frame = _frame_for(solid)
	else:
		sprite.visible = solid
		sprite.frame = 0

func _set_open(open: bool) -> void:
	is_open = open
	shape.set_deferred("disabled", open)


func _inverted_step(delta: float, pressed: bool) -> void:
	var flash := flash_time if use_buffer else 0.0
	var hold := hold_open_time if use_buffer else 0.0
	var flashing = false
	var base_solid := false
	
	match inv_state:
		Inv.GONE:
			if pressed:
				if flash > 0.0:
					inv_state = Inv.APPEARING
					inv_timer = flash
				else:
					_inv_become_solid(hold)
		Inv.APPEARING:
			inv_timer -= delta
			if inv_timer <= 0.0:
				_inv_become_solid(hold)
			else:
				flashing = true
				base_solid = false
		Inv.SOLID:
			if pressed:
				inv_timer = hold
			else:
				inv_timer -= delta
				if inv_timer <= 0.0:
					if flash > 0.0:
						inv_state = Inv.VANISHING
						inv_timer = flash
						shape.set_deferred("disabled", true)
					else:
						_inv_become_gone()
		Inv.VANISHING:
			inv_timer -= delta
			if inv_timer <= 0.0:
				_inv_become_gone()
			else:
				flashing = true
				base_solid = true
				
	if flashing:
		var solid := base_solid
		var seg := mini(int(inv_timer / (flash / 4.0)), 3)
		if seg % 2 == 1:
			solid = not solid
		sprite.frame = _frame_for(solid)
	else:
		sprite.frame = _frame_for(inv_state == Inv.SOLID)
	sprite.visible = true
	
func _inv_become_solid(hold: float) -> void:
	inv_state = Inv.SOLID
	inv_timer = hold
	_set_open(false)

func _inv_become_gone() -> void:
	inv_state = Inv.GONE
	_set_open(true)
