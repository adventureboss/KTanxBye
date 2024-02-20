extends Marker2D

@export var turning_increment: float = 45.0
@export var turning_duration: float = 0.2

@onready var rotate_tween: Tween = create_tween()
@onready var parent: Node = get_parent()
var current_rotation = 0

var tank_id

func _ready():
	tank_id = get_parent().tank_id

func _process(_delta):
	if multiplayer.get_unique_id() != parent.get_tank_authority():
		return
	
	var movement_vector = parent.get_movement_vector()
	var proposed_rotation = rad_to_deg(movement_vector.angle())
	
	if proposed_rotation < 0:
		proposed_rotation = ceil(proposed_rotation)
	else:
		proposed_rotation = floor(proposed_rotation)

	# the tank should find a shorter path
	if abs(proposed_rotation - current_rotation) > 180:
		proposed_rotation = proposed_rotation * -1

	# the tank shouldnt keep turning when the player isn't moving
	if movement_vector == Vector2.ZERO and rotate_tween.is_running():
		rotate_tween.kill()
		current_rotation = self.rotation_degrees
	elif movement_vector != Vector2.ZERO and proposed_rotation != current_rotation and !rotate_tween.is_valid():
		rotate_tween = create_tween()
		rotate_tween.tween_method(turn_tank, current_rotation, proposed_rotation, turning_duration).set_ease(Tween.EASE_OUT)
		current_rotation = proposed_rotation

func turn_tank(degrees: float):
	# Going to make the movement rigid, so turning at distinct increments
	self.rotation_degrees = round(degrees / turning_increment) * turning_increment
