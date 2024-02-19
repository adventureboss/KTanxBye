extends Node2D

@export var PlayerScene : PackedScene

var players = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	# faking some characters
	players = [{
		"id": 1398740987,
		"name": "Peerless",
		"color": "Pink"
	},
	{
		"id": 23453463456,
		"name": "Flightless",
		"color": "Red"
	},
	{
		"id": 34563456345,
		"name": "BulletHealer",
		"color": "Blue"
	},
	{
		"id": 1,
		"name": "History",
		"color": "Green"
	}]
	GameManager.tanks = players
	var i = 0
	for p in players:
		var current_player = PlayerScene.instantiate()
		current_player.name = str(p.id)
		add_child(current_player)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoints"):
			if spawn.name == str(i):
				current_player.global_position = spawn.global_position
		i += 1
