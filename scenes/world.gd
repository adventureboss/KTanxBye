extends Node2D

@export var PlayerScene : PackedScene

@onready var multiplayer_manager : MultiplayerManager = get_tree().get_first_node_in_group("MultiplayerManager")
@onready var round_timer = $RoundTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	var i = 0
	for p in GameManager.players:
		var current_player = PlayerScene.instantiate()
		current_player.name = str(GameManager.players[p].id)
		current_player.get_node("HealthComponent").died.connect(_on_player_died)
		add_child(current_player)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoints"):
			if spawn.name == str(i):
				current_player.global_position = spawn.global_position
		i += 1

	round_timer.start()

func _on_round_timer_timeout():
	for player in get_tree().get_nodes_in_group("player"):
		player.process_mode = Node.PROCESS_MODE_DISABLED
		# ideas:
		# - camera zoom out
		# - trigger UI round over with scoreboard

func _on_player_died(id, enemy_id):
	multiplayer_manager.update_player_score_by.rpc(id, {"kills": 0, "deaths": 1, "assists": 0})
	multiplayer_manager.update_player_score_by.rpc(enemy_id, {"kills": 1, "deaths": 0, "assists": 0})

	# trigger UI screen, etc.
