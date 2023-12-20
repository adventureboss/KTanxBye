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

func receive_players(players):
	for p in players:
		var p_as_int = int(p)
		GameManager.players[p_as_int] = players[p]

@rpc("any_peer")
func send_player_information(id, player_name, color="Blue", score={"kills": 0, "deaths": 0, "assists": 0}):
	if !GameManager.players.has(id):
		GameManager.players[id] = {
			"id": id,
			"name": player_name,
			"color": color,
			"score": score
		}
		load_player_into_lobby.emit(id, player_name, color)
	
	if multiplayer.is_server():
		for i in GameManager.players:
			if i == 10101010:
				continue
			send_player_information.rpc(i, player_name, color, score)

@rpc("any_peer")
func update_player_color(id, color):
	GameManager.players[id].color = color
	update_player_in_lobby.emit(id, GameManager.players[id].name, color)
	 
	for i in GameManager.players:
		if i == 10101010:
			continue
		update_player_color.rpc_id(i, id, color)

@rpc("authority")
func update_player_score_by(id, score):
	var current_score = GameManager.players[id].score
	var new_score = {
		"kills": current_score.kills + score.kills,
		"deaths": current_score.deaths + score.deaths,
		"assists": current_score.assists + score.assists
	}
	GameManager.players[id].score = new_score
	
	for i in GameManager.players:
		if i == 10101010:
			continue
		update_player_score.rpc_id(i, id, new_score)

@rpc("any_peer", "call_local")
func update_player_score(id, score):
	GameManager.players[id].score = score

func on_start_pressed():
	start_game.rpc()

@rpc("call_local")
func on_color_changed(player_color):
	print("on_color_changed" + player_color)
	update_player_color.rpc(multiplayer.get_unique_id(), player_color)
	if multiplayer.get_unique_id() == 1:
		# long store here
		update_player_color(multiplayer.get_unique_id(), player_color)
	for p in GameManager.players:
		if p == 10101010:
			continue
		if GameManager.players[p].id == multiplayer.get_unique_id():
			update_player_in_lobby.emit(multiplayer.get_unique_id(),  GameManager.players[p].name, player_color)
			break

@rpc("any_peer", "call_local")
func start_game():
	scene_manager.load_world()

func collect_player_name():
	return name_field.text

func choose_default_color():
	var options = ["blue", "red", "green", "camo"]
	for p in GameManager.players:
		if p == 10101010:
			continue
		print(GameManager.players[p].color)
		options.erase(GameManager.players[p].color)
	
	return options[0]
