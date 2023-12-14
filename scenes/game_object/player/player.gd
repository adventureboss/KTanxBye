extends CharacterBody2D

const MAX_SPEED = 300.0
const ACCELERATION_SMOOTHING = 25

@onready var barrel_tip: Marker2D = $Barrel
@onready var tank_body: Sprite2D = $TankBody/Sprite2D

func _process(delta):
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()
	var target_velocity = direction * MAX_SPEED
	var mouse_position = get_global_mouse_position()
	
	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	
	move_and_slide()
	
	barrel_tip.look_at(mouse_position)
	
	if movement_vector == Vector2(-1, 0) or movement_vector == Vector2(1, 0):
		tank_body.rotation = 90
	if movement_vector == Vector2(0, 1) or movement_vector == Vector2(0, -1):
		tank_body.rotation = 0
	if movement_vector == Vector2(-1, 1) or movement_vector == Vector2(1, -1):
		tank_body.rotation = 45
		
	
	#var move_sign = sign(movement_vector.x)
	#if move_sign != 0:
		#visuals.scale = Vector2(move_sign, 1)


func get_movement_vector():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	return Vector2(x_movement, y_movement)
	
