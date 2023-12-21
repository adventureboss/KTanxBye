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
@onready var emote = load("res://scenes/game_object/player/emote.tscn")

@onready var previous_movement: Vector2 = Vector2.ZERO

var player_id

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	player_id = str(name).to_int()
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		$Camera2D.make_current()
		health_component.health_changed.connect(on_health_changed)
		var tank_color = GameManager.players[player_id].color
		set_tank_texture.rpc(player_id, tank_color)
		set_player_name.rpc(player_id)
	emote = emote.instantiate()
	emote.player_id = player_id
	add_child(emote)
		
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
		boost_icons[0].visible = false # available icon
		boost_icons[1].visible = true # unavailable icon
	
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
		boost_icons[0].visible = true
		boost_icons[1].visible = false

@rpc("any_peer", "call_local")
func show_emote_sprite(path):
	print("any_peer, call local should call everybody %d" % multiplayer.get_unique_id())
	emote.start_emote(path)
