extends Node

@onready var timer : Timer = $Timer
@onready var total_consumables : int = 0
@onready var current_ammo : int = 0
@onready var current_buffs : int = 0
@onready var buffs_to_drop : int = 5
@onready var ammo_to_drop : int = 5

# preload the boxes we want
@onready var rapid_fire_pickup = preload("res://scenes/game_object/collectible/rapid_fire_pickup.tscn")
@onready var spread_pickup = preload("res://scenes/game_object/collectible/spread_pickup.tscn")
@onready var laser_pickup = preload("res://scenes/game_object/collectible/laser_pickup.tscn")
@onready var bazooka_pickup = preload("res://scenes/game_object/collectible/bazooka_pickup.tscn")
@onready var animated_drop = preload("res://scenes/game_object/collectible/collectible_spawn.tscn")

@export var max_buffs : int = 5
@export var max_ammo : int = 10

@onready var consumable_spawn_points : Array[Node]
@onready var ammo_list : Array[PackedScene] = [
	rapid_fire_pickup,
	spread_pickup,
	laser_pickup,
	bazooka_pickup,
]
var box_tracker = {}


func _ready():
	var ammo_index : Array = [0, 1, 2, 3]
	var consumable_positions = []
	GameEvents.ability_pick_up.connect(on_ability_pickup)
	if multiplayer.get_unique_id() == GameManager.player_host:
		consumable_spawn_points = get_tree().get_nodes_in_group("ConsumableSpawnPoints")
		randomize()
		consumable_spawn_points.shuffle()
		for marker in consumable_spawn_points:
			randomize()
			ammo_index.shuffle()
			consumable_positions.append({"position": marker.global_position, "ammo_index": ammo_index[0]})
		new_spawn_at_points.rpc(consumable_positions, box_tracker)


@rpc("any_peer", "call_local")
func new_spawn_at_points(consumable_positions, tracker):
	for p in consumable_positions:
		if p.position in tracker and tracker[p.position] == 1:
			continue
		var ammo_to_spawn = ammo_list[p.ammo_index]
		var pickup = ammo_to_spawn.instantiate()
		add_child(pickup)
		tracker[p.position] = 1 # tracking that this position has a box
		pickup.global_position = p.position
	box_tracker = tracker
	count_consumables()
	timer.timeout.connect(on_timer_timeout)
	timer.start()


func count_consumables():
	total_consumables = get_tree().get_nodes_in_group("consumables").size()
	current_ammo = get_tree().get_nodes_in_group("ammo").size()
	current_buffs = get_tree().get_nodes_in_group("buff").size()


func count_consumable_drop():
	buffs_to_drop = max_buffs - current_buffs
	ammo_to_drop = max_ammo - current_ammo


func on_timer_timeout():
	if multiplayer.get_unique_id() != GameManager.player_host:
		return
	count_consumables()
	count_consumable_drop()
	
	var ammo_index : Array = [0, 1, 2]
	var consumable_positions = []
	randomize()
	consumable_spawn_points.shuffle()
	for marker in consumable_spawn_points:
		randomize()
		ammo_index.shuffle()
		consumable_positions.append({"position": marker.global_position, "ammo_index": ammo_index[0]})
	respawn_at_points.rpc(consumable_positions, box_tracker)


@rpc("any_peer", "call_local")
func respawn_at_points(consumable_positions, tracker):
	for p in consumable_positions:
		if p.position in tracker and tracker[p.position] == 1:
			continue
		var drop = animated_drop.instantiate()
		add_child(drop)
		box_tracker[p.position] = 1
		var drop_hitbox = drop.find_child("HitboxComponent")
		drop.global_position = p.position
		drop_hitbox.get_parent().projectile_owner = owner # this is why the spawn node is 10101010. Stupid. FIX IT
		var anim_player : AnimationPlayer = drop.find_child("AnimationPlayer")
		anim_player.play("drop")
		anim_player.animation_finished.connect(on_animation_finished.bind(p.position, p.ammo_index))
	box_tracker = tracker


func on_ability_pickup(_ability, _id, position):
	box_tracker[position] = 0
		
	
func on_animation_finished(anim_name, position, ammo_index):
	var ammo_to_spawn = ammo_list[ammo_index]
	var pickup = ammo_to_spawn.instantiate()
	add_child(pickup)
	pickup.global_position = position
