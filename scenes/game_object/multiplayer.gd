extends Node2D

@export var player_scene: PackedScene
@export var address = "localhost"
@export var port = 135

var peers: Array[ENetMultiplayerPeer]

@export var spawn_points: Array[Marker2D]
var spawn_index = 0

@export var join_button: Button
@export var host_button: Button

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

# a lot of these settings I got from this video
# https://youtu.be/e0JLO_5UgQo?si=JCtArm_CeiQD4wBb
func _on_host_pressed():
	print("host pressed")
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 4) # this second value is maximum number of peers
	if error != OK:
		print("error occured hosting" + error)

	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	host_button.set_visible(false)
	join_button.set_visible(false)

func _on_join_pressed():
	print("join_pressed")
	#peer.create_client(address, port)
	#multiplayer.multiplayer_peer = peer
	
	host_button.set_visible(false)
	join_button.set_visible(false)

# called on server and all clients
func peer_connected(id = 1):
	print("peer connected: " + id)
	var player = player_scene.instantiate()
	player.name = str(id)
	
	player.position = spawn_points[spawn_index].position
	print(player.position)
	spawn_index += 1
	call_deferred("add_child", player)

# same as connnected
func peer_disconnected(id):
	print("peer disconnected: " + str(id))

# called only from clients
func connected_to_server(id):
	print("Player connected to server: " + str(id))

# called only from clients
func connection_failed(id):
	print("Player failed to connect: " + str(id))
