class_name Player extends CharacterBody2D

const MAX_SPEED = 300.0
const ACCELERATION_SMOOTHING = 25
var can_boost = true

@onready var health_component : HealthComponent = $HealthComponent
@onready var health_bar : ProgressBar = $HealthBar/ProgressBar
@onready var barrel_tip: Marker2D = $Barrel
@onready var tank_body: Sprite2D = $TankBody/Sprite2D
@onready var barrel_color: Sprite2D = $Barrel/Sprite2D
@onready var boost_timer: Timer = $BoostTimer
@export var boost_icons: Array[TextureRect]
@onready var player_name: Label = $PlayerName
@onready var player_marker: Node2D = %PlayerMarker
@export var boost_available: TextureRect
@export var boost_unavailable: TextureRect
@onready var emote = load("res://scenes/game_object/player/emote.tscn")
@export var emote_wheel: Control

@onready var previous_movement: Vector2 = Vector2.ZERO

var player_id: int

func _ready():
	player_id = str(name).to_int()
	print("setting player_id %d" % player_id)
	# although the player is not in control of most things now,
	# I think it is an easy approach for position, etc.
	$MultiplayerSynchronizer.set_multiplayer_authority(player_id)
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
		health_component.health_changed.connect(on_health_changed)
		player_marker.disable()
		var tank_color = GameManager.players[player_id].color
		set_tank_texture.rpc(player_id, tank_color)
		set_player_name.rpc(player_id)
	else:
		player_marker.enable(GameManager.players[player_id].name)
		
		boost_available.visible = false
		boost_unavailable.visible = false
	emote = emote.instantiate()
	emote.player_id = player_id
	add_child(emote)
	emote_wheel.player_id_what = player_id

func get_player_id():
	return player_id

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
	if multiplayer.get_unique_id() == id:
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
	if multiplayer.get_unique_id() != player_id:
		return
	
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()
	var target_velocity = direction * MAX_SPEED

	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	
	if Input.is_action_pressed("boost") and can_boost:
		apply_boost(direction)
		can_boost = false
		boost_timer.start()
		boost_available.visible = false
		boost_unavailable.visible = true
	
	move_and_slide()

func get_movement_vector():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	return Vector2(x_movement, y_movement)

func apply_boost(direction: Vector2):
	var boost_strength = 2500.0
	velocity += direction * boost_strength

@rpc("any_peer", "call_local")
func update_health_display():
	health_bar.value = health_component.get_health_value()
	if health_bar.value <= 0:
		health_bar.visible = false
		return
	elif !health_bar.visible:
		health_bar.visible = true

func on_health_changed():
	update_health_display.rpc()

func _on_boost_timer_timeout():
	if can_boost == false:
		can_boost = true
		boost_available.visible = true
		boost_unavailable.visible = false

@rpc("any_peer", "call_local")
func show_emote_sprite(id, path):
	emote.start_emote(id, path)
