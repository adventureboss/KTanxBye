extends Node2D

@export var PlayerScene : PackedScene

@onready var multiplayer_manager : MultiplayerManager = get_tree().get_first_node_in_group("MultiplayerManager")
@onready var round_timer = $RoundTimer
@onready var round_timer_ui = $RoundTimerUI/Time 

# Called when the node enters the scene tree for the first time.
func _ready():
	var i = 0
	for p in GameManager.players:
		if p == GameManager.ENVIRONMENT:
			continue
		var current_player = PlayerScene.instantiate()
		current_player.name = str(GameManager.players[p].id)
		current_player.get_node("HealthComponent").died.connect(_on_player_died)
		add_child(current_player)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoints"):
			if spawn.name == str(i):
				current_player.global_position = spawn.global_position
		i += 1

	round_timer.start()

func _process(delta):
	if round_timer and round_timer_ui:
		var time_elapsed = round_timer.time_left
		round_timer_ui.text = format_seconds_to_string(time_elapsed)

func format_seconds_to_string(seconds: float):
	var minutes = floor(seconds / 60)
	var remaining_seconds = seconds - (minutes * 60)
	return str(minutes) + ":" + ("%02d" % floor(remaining_seconds))

func _on_round_timer_timeout():
	for player in get_tree().get_nodes_in_group("player"):
		player.process_mode = Node.PROCESS_MODE_DISABLED
		get_node("../../CanvasLayer/Scoreboard").show_scoreboard()
		# ideas:
		# - camera zoom out
		# - trigger UI round over with scoreboard

func _on_round_timer_reset():
	for player in get_tree().get_nodes_in_group("player"):
		player.process_mode = Node.PROCESS_MODE_INHERIT
		get_node("../../CanvasLayer/Scoreboard").hide_scoreboard()

func _on_player_died(id, enemy_id):
	var current_score = GameManager.players[id].score
	multiplayer_manager.update_player_score.rpc_id(GameManager.player_host, id, {
		"kills": current_score.kills, 
		"deaths": current_score.deaths + 1, 
		"assists": current_score.assists
	})
	multiplayer_manager.update_player_score.rpc_id(GameManager.player_host, enemy_id, {
		"kills": current_score.kills + 1, 
		"deaths": current_score.deaths,
		"assists": current_score.assists
	})
	# trigger UI screen, respawn, etc.
