extends Node2D

@export var PlayerScene: PackedScene

@onready var multiplayer_manager: MultiplayerManager = get_tree().get_first_node_in_group("MultiplayerManager")
@onready var scene_manager: Node2D = get_tree().get_first_node_in_group("SceneManager")
@onready var music: AudioStreamPlayer = get_node("AudioStreamPlayer")
@export var scoreboard: Control
@onready var round_timer = $RoundTimer
@onready var round_timer_ui = %Time

signal one_minute_left

# Called when the node enters the scene tree for the first time.
func _ready():
	one_minute_left.connect(on_one_minute_left)
	set_multiplayer_authority(scene_manager.get_multiplayer_authority())
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
		# change the timer to red. This feels weird but it shouldn't continue
		# to change the color every frame, so a one time signal seems like a decent
		# method
		if round_timer.time_left < 60 && round_timer.time_left > 59:
			one_minute_left.emit()

func format_seconds_to_string(seconds: float):
	var minutes = floor(seconds / 60)
	var remaining_seconds = seconds - (minutes * 60)
	return str(minutes) + ":" + ("%02d" % floor(remaining_seconds))

func _on_round_timer_timeout():
	for player in get_tree().get_nodes_in_group("player"):
		player.process_mode = Node.PROCESS_MODE_DISABLED
		scoreboard.show_scoreboard(true)
		# ideas:
		# - camera zoom out
		# - trigger UI round over with scoreboard

func _on_continue_pressed():
	continue_round.rpc()
	multiplayer_manager.reset_game.rpc()

@rpc("any_peer", "call_local")
func continue_round():
	for player in get_tree().get_nodes_in_group("player"):
		player.process_mode = Node.PROCESS_MODE_INHERIT
	scoreboard.hide_scoreboard()
	music.play()
	round_timer.start()

func _on_return_to_menu_pressed():
	quit_all.rpc()

@rpc("any_peer", "call_local")
func quit_all():
	scene_manager.load_scene("start")

func _on_player_died(id, enemy_id):
	var currently_dead_score = GameManager.players[id].score
	multiplayer_manager.update_player_score.rpc_id(GameManager.player_host, id, {
		"kills": currently_dead_score.kills, 
		"deaths": currently_dead_score.deaths + 1, 
		"assists": currently_dead_score.assists
	})
	var currently_active_score = GameManager.players[enemy_id].score
	multiplayer_manager.update_player_score.rpc_id(GameManager.player_host, enemy_id, {
		"kills": currently_active_score.kills + 1, 
		"deaths": currently_active_score.deaths,
		"assists": currently_active_score.assists
	})
	# trigger UI screen, respawn, etc.

func on_one_minute_left():
	var animation_player = $RoundTimerUI/AnimationPlayer
	round_timer_ui.add_theme_color_override("default_color", Color8(208, 0, 0, 255))
	animation_player.play("bounce_timer")

