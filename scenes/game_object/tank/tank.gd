class_name Tank extends CharacterBody2D

const MAX_SPEED = 300.0
const ACCELERATION_SMOOTHING = 25
var can_boost = true

@onready var health_component : HealthComponent = $HealthComponent
@onready var health_bar : ProgressBar = $HealthBar/ProgressBar
@onready var barrel_tip: Marker2D = $Barrel
@onready var tank_body: Sprite2D = $TankBody/Sprite2D
@onready var barrel_color: Sprite2D = $Barrel/Sprite2D
@onready var boost_timer: Timer = $BoostTimer
@onready var tank_name: Label = $TankName

@onready var emote = load("res://scenes/game_object/tank/emote.tscn")

@onready var previous_movement: Vector2 = Vector2.ZERO

var tank_id: int

func _init():
	allow_instantiation()
	
func allow_instantiation():
	assert(false, "The tank class is cannot be instantiated")

func _ready():
	tank_id = str(name).to_int()
	print("setting tank_id %d" % tank_id)
	# although the player is not in control of most things now,
	# I think it is an easy approach for position, etc.
	$MultiplayerSynchronizer.set_multiplayer_authority(tank_id)
	if multiplayer.get_unique_id() == tank_id:
		health_component.health_changed.connect(on_health_changed)
		var tank_color = GameManager.tanks[tank_id].color
		set_tank_texture.rpc(tank_id, tank_color)
		set_tank_name.rpc(tank_id)

func get_tank_id():
	return tank_id

@rpc("any_peer", "call_local")
func set_tank_name(tank_id):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == tank_id:
		tank_name.text = GameManager.tanks[tank_id].name
	else:
		get_node("../%s/TankName" % tank_id).text = GameManager.tanks[tank_id].name

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
	if multiplayer.get_unique_id() != tank_id:
		return
	
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()
	var target_velocity = direction * MAX_SPEED

	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	
	# calling move_and_slide in the child classes
	_move(delta, direction, velocity)
	
func _move(delta, direction, velocity):
	pass
	
func get_movement_vector():
	return Vector2(0, 0)

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
		return true
	return false
