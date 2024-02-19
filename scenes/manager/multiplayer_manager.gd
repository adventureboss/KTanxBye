class_name MultiplayerManager extends Node

@export var address = "localhost"
@export var port = 8910
var peer # really, this'll be self

@export var scene_manager : Node2D
@export var name_field : LineEdit
var selected_name # storing since we are sending client info after pushing the button
var default_color

signal load_player_into_lobby(id, player_name, player_color)
signal update_player_in_lobby(id, player_name, player_color)

@rpc("any_peer", "call_local")
func receive_players(players):
	set_multiplayer_authority(GameManager.player_host)
	for p in players:
		var p_as_int = int(p)
		GameManager.tanks[p_as_int] = players[p]

@rpc("any_peer")
func send_player_information(id, player_name, color="Blue", score={"kills": 0, "deaths": 0, "assists": 0}):
	if !GameManager.tanks.has(id):
		GameManager.tanks[id] = {
			"id": id,
			"name": player_name,
			"color": color,
			"score": score
		}
		load_player_into_lobby.emit(id, player_name, color)
	
	if multiplayer.is_server():
		for i in GameManager.tanks:
			if i == GameManager.ENVIRONMENT:
				continue
			send_player_information.rpc(i, player_name, color, score)

@rpc("any_peer", "call_local")
func update_player_color(id, color):
	GameManager.tanks[id].color = color
	update_player_in_lobby.emit(id, GameManager.tanks[id].name, color)
	
	if multiplayer.get_unique_id() != GameManager.player_host:
		return
	
	for i in GameManager.tanks:
		if i == GameManager.ENVIRONMENT:
			continue
		update_player_color.rpc_id(i, id, color)

@rpc("any_peer", "call_local")
func update_player_score(id, score):
	GameManager.tanks[id].score = score
	
	if multiplayer.get_unique_id() != GameManager.player_host:
		return
		
	for i in GameManager.tanks:
		if i == GameManager.ENVIRONMENT || i == GameManager.player_host:
			continue
		update_player_score.rpc_id(i, id, score)

@rpc("any_peer", "call_local")
func start_game():
	scene_manager.load_world()

@rpc("any_peer", "call_local")
func reset_game():
	# currently, just resets score board
	for p in GameManager.tanks:
		if p == GameManager.ENVIRONMENT:
			continue
		GameManager.tanks[p].score = {"kills": 0, "deaths": 0, "assists": 0}
