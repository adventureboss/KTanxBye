extends Node

@export var scene_manager : Node2D
@export var address = "localhost"
@export var port = 135
var peer # really, this'll be self

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

func on_start_pressed():
	start_game.rpc()

@rpc("any_peer", "call_local")
func on_ready_pressed(player_name, player_color):
	print("on_ready_pressed" + player_name + player_color)
	send_player_information.rpc(multiplayer.get_unique_id(), player_name, player_color)
	if multiplayer.get_unique_id() == 1:
		# long store here
		send_player_information(multiplayer.get_unique_id(), player_name, player_color)

@rpc("any_peer", "call_local")
func start_game():
	scene_manager.load_world()

@rpc("any_peer")
func send_player_information(id, name, color, score=0):
	if !GameManager.players.has(id):
		GameManager.players[id] = {
			"id": id,
			"name": name,
			"color": color,
			"score": score
		}
	
	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_information.rpc(i, name, color, score)

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
	
	scene_manager.load_scene("lobby")

func _on_join_pressed():
	print("join_pressed")
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	
	scene_manager.load_scene("lobby")
	
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

# called only from clients
func connection_failed():
	var id = multiplayer.get_unique_id()
	print("player failed to connect: " + str(id))
