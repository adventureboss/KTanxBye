extends Node

@export var address = "localhost"
@export var port = 135
var peer # really, this'll be self

@export var scene_manager : Node2D
@export var name_field : LineEdit
var selected_name # storing since we are sending client info after pushing the button
var default_color

signal load_player_into_lobby(id, player_name, player_color)
signal update_player_in_lobby(id, player_name, player_color)

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

@rpc("any_peer")
func send_player_information(id, player_name, color="blue", score=0):
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
			send_player_information.rpc(i, player_name, color, score)

@rpc("any_peer")
func update_player_color(id, color):
	GameManager.players[id].color = color
	update_player_in_lobby.emit(id, GameManager.players[id].name, color)
	 
	if multiplayer.is_server():
		for i in GameManager.players:
			update_player_color.rpc(i, color)

@rpc("any_peer")
func update_player_score(id, score):
	GameManager.players[id]["score"] = score
	
	if multiplayer.is_server():
		for i in GameManager.players:
			update_player_color.rpc(i, score)

# a lot of these settings I got from this video
# https://youtu.be/e0JLO_5UgQo?si=JCtArm_CeiQD4wBb
func _on_host_pressed():
	print("host_pressed")
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 4) # this second value is maximum number of peers
	if error != OK:
		print("error occured hosting" + error)
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
	selected_name = collect_player_name()
	scene_manager.load_lobby()
	
	send_player_information(multiplayer.get_unique_id(), selected_name)

func _on_join_pressed():
	print("join_pressed")
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	selected_name = collect_player_name()
	scene_manager.load_lobby()
	
func on_start_pressed():
	start_game.rpc()

@rpc("any_peer", "call_local")
func on_color_changed(player_color):
	print("on_color_changed" + player_color)
	update_player_color.rpc(multiplayer.get_unique_id(), player_color)
	if multiplayer.get_unique_id() == 1:
		# long store here
		update_player_color(multiplayer.get_unique_id(), player_color)
	update_player_in_lobby.emit(multiplayer.get_unique_id(), player_color)

@rpc("any_peer", "call_local")
func start_game():
	scene_manager.load_world()

# called on server and all clients
func peer_connected(id = 1):
	print("peer connected: " + str(id))

# same as connnected
func peer_disconnected(id):
	print("peer disconnected: " + str(id))

# called only from clients
func connected_to_server():
	var id = multiplayer.get_unique_id()
	print("player connected to server: " + str(id))
	send_player_information.rpc(id, selected_name)

# called only from clients
func connection_failed():
	var id = multiplayer.get_unique_id()
	print("player failed to connect: " + str(id))

func collect_player_name():
	return name_field.text

func choose_default_color():
	var options = ["blue", "red", "green", "camo"]
	for p in GameManager.players:
		print(GameManager.players[p].color)
		options.erase(GameManager.players[p].color)
	
	return options[0]
