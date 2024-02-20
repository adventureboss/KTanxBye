extends Node2D

@export var PlayerScene: PackedScene
@export var BotScene: PackedScene
@export var map_time : int = 300 # make this configurable for future maps

@onready var multiplayer_manager: MultiplayerManager = get_tree().get_first_node_in_group("MultiplayerManager")
@onready var arena_time_manager : ArenaTimeManager = get_tree().get_first_node_in_group("ArenaTimeManager")
@onready var scene_manager: Node2D = get_tree().get_first_node_in_group("SceneManager")
@onready var music: AudioStreamPlayer = get_node("AudioStreamPlayer")
@export var scoreboard: Control
@onready var round_timer_ui = %Time

@onready var countdown = $Countdown
var player_camera: Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	arena_time_manager.one_minute_left.connect(on_one_minute_left)
	set_multiplayer_authority(scene_manager.get_multiplayer_authority())
	var i = 0
	for p in GameManager.tanks:
		if p == GameManager.ENVIRONMENT:
			continue
		var current_tank
		if GameManager.tanks[p].bot:
			current_tank = BotScene.instantiate()
		else:
			current_tank = PlayerScene.instantiate()
		current_tank.name = str(GameManager.tanks[p].id)
		current_tank.get_node("HealthComponent").died.connect(_on_player_died)
		add_child(current_tank)
		if multiplayer.get_unique_id() == GameManager.tanks[p].id:
			player_camera = current_tank.get_node("Camera2D")
		
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoints"):
			if spawn.name == str(i):
				current_tank.global_position = spawn.global_position
		i += 1

	arena_time_manager.pause_round()
	countdown.start_countdown(player_camera)
	
	await countdown.countdown_completed
	
	continue_round()
	arena_time_manager.start(map_time)

func _process(delta):
	if round_timer_ui:
		if countdown.time_left() > 0:
			round_timer_ui.text = arena_time_manager.format_time(countdown.time_left())
		else:
			var time_elapsed = arena_time_manager.time_left()
			round_timer_ui.text = arena_time_manager.format_time(time_elapsed)


func _on_continue_pressed():
	continue_round.rpc()
	multiplayer_manager.reset_game.rpc()


@rpc("any_peer", "call_local")
func continue_round():
	for player in get_tree().get_nodes_in_group("Tanks"):
		player.process_mode = Node.PROCESS_MODE_INHERIT
	if scoreboard != null:
		scoreboard.hide_scoreboard()
	music.play()
	arena_time_manager.start(map_time)

func _on_return_to_menu_pressed():
	quit_all.rpc()

@rpc("any_peer", "call_local")
func quit_all():
	scene_manager.load_scene("start")

func _on_player_died(id, enemy_id):
	var currently_dead_score = GameManager.tanks[id].score
	multiplayer_manager.update_player_score.rpc_id(GameManager.player_host, id, {
		"kills": currently_dead_score.kills, 
		"deaths": currently_dead_score.deaths + 1, 
		"assists": currently_dead_score.assists
	})
	var currently_active_score = GameManager.tanks[enemy_id].score
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

