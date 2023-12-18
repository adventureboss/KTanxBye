extends Node

@onready var timer : Timer = $Timer
@onready var total_consumables : int = 0
@onready var current_ammo : int = 0
@onready var current_buffs : int = 0
@onready var buffs_to_drop : int = 5
@onready var ammo_to_drop : int = 5

# preload the boxes we want
@onready var rapid_fire_pickup = preload("res://scenes/game_object/collectible/rapid_fire_pickup.tscn")
@onready var spread_pick = preload("res://scenes/game_object/collectible/spread_pickup.tscn")

@export var max_buffs : int = 5
@export var max_ammo : int = 5

@onready var consumable_spawn_points : Array[Node]

func _ready():
	consumable_spawn_points = get_tree().get_nodes_in_group("ConsumableSpawnPoints")
	randomize()
	consumable_spawn_points.shuffle()
	for marker in consumable_spawn_points:
		for ammo_box in ammo_to_drop:
			var pickup = rapid_fire_pickup.instantiate()
			add_child(pickup)
			pickup.global_position = marker.global_position

	count_consumables()
	timer.timeout.connect(on_timer_timeout)


func count_consumables():
	total_consumables = get_tree().get_nodes_in_group("consumables").size()
	current_ammo = get_tree().get_nodes_in_group("ammo").size()
	current_buffs = get_tree().get_nodes_in_group("buff").size()

func count_consumable_drop():
	buffs_to_drop = max_buffs - current_buffs
	ammo_to_drop = max_ammo - current_ammo

func on_timer_timeout():
	count_consumables()
	count_consumable_drop()

	
	
	

