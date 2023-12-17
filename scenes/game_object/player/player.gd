extends CharacterBody2D

const MAX_SPEED = 300.0
const ACCELERATION_SMOOTHING = 25

@onready var barrel_tip: Marker2D = $Barrel
@onready var tank_body: Sprite2D = $TankBody/Sprite2D
@onready var barrel_color: Sprite2D = $Barrel/Sprite2D

@onready var diagonal_movement: Array = [Vector2(-1, -1), Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1)]
@onready var previous_movement: Vector2 = Vector2.ZERO

func _ready():
	var player_id = multiplayer.get_unique_id()
	if $MultiplayerSynchronizer.get_multiplayer_authority() == player_id:
		$Camera2D.make_current()
		
		var tank_color = GameManager.players[player_id].color
		tank_body.texture = load(GameManager.color_dict[tank_color]["Body"])
		tank_body.scale = Vector2(0.5, 0.5)
		barrel_color.texture = load(GameManager.color_dict[tank_color]["Barrel"])
		barrel_color.scale = Vector2(0.5, 0.5)


func _process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()
	var target_velocity = direction * MAX_SPEED
	var mouse_position = get_global_mouse_position()

	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))

	move_and_slide()
	barrel_tip.look_at(mouse_position)

func get_movement_vector():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	return Vector2(x_movement, y_movement)

func _enter_tree():
	$MultiplayerSynchronizer.set_multiplayer_authority(name.to_int())
