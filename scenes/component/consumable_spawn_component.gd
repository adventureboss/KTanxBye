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
@onready var animated_drop = preload("res://scenes/game_object/collectible/collectible_spawn.tscn")

@export var max_buffs : int = 5
@export var max_ammo : int = 10

@onready var consumable_spawn_points : Array[Node]
@onready var ammo_list : Array[PackedScene] = [
	rapid_fire_pickup,
	spread_pickup,
	laser_pickup
]
var box_tracker = {}


func _ready():
	GameEvents.ability_pick_up.connect(on_ability_pickup)
	consumable_spawn_points = get_tree().get_nodes_in_group("ConsumableSpawnPoints")
	randomize()
	consumable_spawn_points.shuffle()
	for marker in consumable_spawn_points:
		ammo_list.shuffle()
		var ammo_to_spawn = ammo_list[0]
		var pickup = ammo_to_spawn.instantiate()
		add_child(pickup)
		box_tracker[marker.global_position] = 1 # tracking that this position has a box
		pickup.global_position = marker.global_position

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


func spawn_new_consumables():
	for marker in consumable_spawn_points:	
		if box_tracker[marker.global_position] == 1:
			continue
		var drop = animated_drop.instantiate()
		add_child(drop)
		box_tracker[marker.global_position] = 1
		var drop_hitbox = drop.find_child("HitboxComponent")
		drop.global_position = marker.global_position
		drop_hitbox.get_parent().projectile_owner = owner # this is why the spawn node is 10101010. Stupid. FIX IT
		var anim_player : AnimationPlayer = drop.find_child("AnimationPlayer")
		anim_player.play("drop")
		anim_player.animation_finished.connect(on_animation_finished.bind(marker.global_position))


func on_timer_timeout():
	count_consumables()
	count_consumable_drop()

	spawn_new_consumables()

func on_ability_pickup(_ability, _id, position):
	box_tracker[position] = 0
		
	
func on_animation_finished(anim_name, position):
	randomize()
	ammo_list.shuffle()
	var ammo_to_spawn = ammo_list[0]
	var pickup = ammo_to_spawn.instantiate()
	add_child(pickup)
	pickup.global_position = position
		

