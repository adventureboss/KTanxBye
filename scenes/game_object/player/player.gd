extends CharacterBody2D

const MAX_SPEED = 300.0
const ACCELERATION_SMOOTHING = 25
var can_boost = true

@onready var barrel_tip: Marker2D = $Barrel
@onready var tank_body: Sprite2D = $TankBody/Sprite2D
@onready var barrel_color: Sprite2D = $Barrel/Sprite2D
@onready var boost_timer: Timer = $BoostTimer
@onready var player_name : Label = $PlayerName


@onready var previous_movement: Vector2 = Vector2.ZERO

func _ready():
	var player_id = multiplayer.get_unique_id()
	if $MultiplayerSynchronizer.get_multiplayer_authority() == player_id:
		$Camera2D.make_current()
		
		var tank_color = GameManager.players[player_id].color
		set_tank_texture.rpc(player_id, tank_color)
		set_player_name.rpc(player_id)
		
@rpc("any_peer", "call_local")
func set_player_name(player_id):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == player_id:
		player_name.text = GameManager.players[player_id].name
	else:
		get_node("../%s/PlayerName" % player_id).text = GameManager.players[player_id].name
	

@rpc("any_peer", "call_local")
func set_tank_texture(id, tank_color):
	var body
	var barrel
	if $MultiplayerSynchronizer.get_multiplayer_authority() == id:
		body = tank_body
		barrel = barrel_color
	else:
		body = get_node("../%s/TankBody/Sprite2D" % id)
		barrel = get_node("../%s/Barrel/Sprite2D" % id)
	body.texture = load(GameManager.color_dict[tank_color]["Body"])
	body.scale = Vector2(0.5, 0.5)
	barrel.texture = load(GameManager.color_dict[tank_color]["Barrel"])
	barrel.scale = Vector2(0.5, 0.5)


func _process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()
	var target_velocity = direction * MAX_SPEED

	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	
	if Input.is_action_pressed("boost") and can_boost:
		apply_boost(direction)
		can_boost = false
		boost_timer.start()
		
	if boost_timer.is_stopped() and can_boost == false:
		can_boost = true
	
	move_and_slide()

func get_movement_vector():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	return Vector2(x_movement, y_movement)

func _enter_tree():
	$MultiplayerSynchronizer.set_multiplayer_authority(name.to_int())

func apply_boost(direction: Vector2):
	var boost_strength = 2500.0
	velocity += direction * boost_strength
