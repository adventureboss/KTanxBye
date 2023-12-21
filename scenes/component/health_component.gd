extends Node
class_name HealthComponent

signal died(id, enemy_id)
signal health_changed

@onready var respawn_timer: Timer = $RespawnTimer
@onready var explosion_animation: AnimatedSprite2D = get_parent().find_child("Explosion")
@onready var tank_body: Marker2D = get_parent().find_child("TankBody")
@onready var tank_barrel: Marker2D = get_parent().find_child("Barrel")
@onready var health_bar: PanelContainer = get_parent().find_child("HealthBar")
@onready var player_name: Label = get_parent().find_child("PlayerName")
@onready var collision: CollisionShape2D = get_parent().find_child("CollisionShape2D")
@onready var hit_collision: CollisionShape2D = get_parent().find_child("HurtboxComponent").find_child("CollisionShape2D2")

@export var max_health: float = 100
var current_health

func _ready():
	current_health = max_health
	respawn_timer.timeout.connect(respawn)

@rpc("any_peer", "call_local")
func damage(id, enemy_id, damage_amount: float):
	current_health = max(current_health - damage_amount, 0)
	health_changed.emit()
	Callable(check_death).call_deferred(id, enemy_id)

func get_health_percent():
	if max_health <= 0:
		return 0
	return min(current_health / max_health, 1)
	
func get_health_value():
	return current_health

func check_death(id, enemy_id):
	if current_health == 0:
		died.emit(id, enemy_id)
		#owner.queue_free()
		owner.process_mode = Node.PROCESS_MODE_DISABLED
		explosion_animation.visible = true
		tank_body.visible = false
		tank_barrel.visible = false
		health_bar.visible = false
		player_name.visible = false
		collision.disabled = true
		hit_collision.disabled = true
		explosion_animation.play()
		respawn_timer.start()

func respawn():
	var spawn_points = get_tree().get_nodes_in_group("PlayerRespawnPoints")
	randomize()
	spawn_points.shuffle()
	ensure_correct_health.rpc()
	if get_parent().find_child("Barrel"):
		get_parent().find_child("Barrel").update_ammo(GameManager.abilities[0], owner.multiplayer.get_unique_id(), null)
	owner.global_position = spawn_points[0].global_position
	
	owner.process_mode = Node.PROCESS_MODE_INHERIT
	explosion_animation.visible = false
	tank_body.visible = true
	tank_barrel.visible = true
	health_bar.visible = true
	player_name.visible = true
	collision.disabled = false
	hit_collision.disabled = false

@rpc("any_peer", "call_local")
func ensure_correct_health():
	current_health = 50
	health_changed.emit()
