extends Node2D

@export var PlayerScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var i = 0
	for p in GameManager.players:
		var current_player = PlayerScene.instantiate()
		current_player.name = str(GameManager.players[p].id)
		add_child(current_player)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoints"):
			if spawn.name == str(i):
				current_player.global_position = spawn.global_position
		i += 1
