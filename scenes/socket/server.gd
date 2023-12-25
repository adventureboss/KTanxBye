extends Node

enum Message {
	ID,
	JOIN,
	USER_CONNECTED,
	USER_DISCONNECTED,
	LOBBY,
	COLOR,
	CANDIDATE,
	OFFER,
	ANSWER,
	CHECK_IN
}

@export var active = true
@export var host_port = 8915
var peer = WebSocketMultiplayerPeer.new()
var users = {}
var lobbies = {}

var characters ="abcdefghijklmnopqrstuvwyzABCDEFGHIJKLMNPQRSTUVWXYZ123456789"

func _ready():
	if "--server" in OS.get_cmdline_args() or active:
		start_server(host_port)
	peer.connect("peer_connected", peer_connected)
	peer.connect("peer_disconnected", peer_disconnected)

func start_server(port):
	var error = peer.create_server(port)
	if error != 0:
		print("error hosting server: %d" % error)
		return
	print("started server; hosting on %d" % port)

func _process(_delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_utf8()
			var data = JSON.parse_string(dataString)
			
			if data.message == Message.USER_DISCONNECTED:
				leave_lobby(data.id, data.lobby_id)
			if data.message == Message.LOBBY:
				join_lobby(data.id, data.lobby_id, data.name)
			if data.message == Message.COLOR:
				change_character_color(data.id, data.lobby_id, data.color)
			if data.message == Message.OFFER || data.message == Message.ANSWER || data.message == Message.CANDIDATE:
				print("original peer id %s" % data.original_peer)
				if data.message == Message.ANSWER:
					print("we are not alone!!!")
				send_to_player(data.peer, data) # passes data to other peer

func join_lobby(user_id, lobby_id, user_name):
	if lobby_id == "":
		lobby_id = generate_lobby_id()
		lobbies[lobby_id] = Lobby.new(user_id)
		print(lobby_id)
	
	if lobby_id not in lobbies:
		print("lobby not found")
		return
	
	var player = lobbies[lobby_id].add_player(user_id, user_name)
	
	for p in lobbies[lobby_id].players:
		# send information to first player in lobby
		var data = {
			"message": Message.USER_CONNECTED,
			"id": user_id
		}
		send_to_player(p, data)
		
		var data2 = {
			"message": Message.USER_CONNECTED,
			"id": p
		}
		send_to_player(user_id, data2)
		
		var lobby_info = {
			"message": Message.LOBBY,
			"players": JSON.stringify(lobbies[lobby_id].players),
			"host": lobbies[lobby_id].host_id,
			"lobby_id": lobby_id
		}
		send_to_player(p, lobby_info)
	
	var player_data = {
		"message": Message.USER_CONNECTED,
		"id": user_id,
		"host": lobbies[lobby_id].host_id,
		"player": lobbies[lobby_id].players[user_id],
		"lobby_id": lobby_id
	}
	send_to_player(user_id, player_data)

func leave_lobby(user_id, lobby_id):
	if !(lobby_id in lobbies):
		return
	var lobby = lobbies[lobby_id]
	lobby.remove_player(user_id)
	if lobby.players.is_empty():
		lobbies.erase(lobby_id)
		return
	
	print("user %d disconnected from lobby %d" % [user_id, lobby_id])
	var lobby_info = {
		"message": Message.LOBBY,
		"players": JSON.stringify(lobbies[lobby_id].players),
		"host": lobbies[lobby_id].host_id,
		"lobby_id": lobby_id
	}
	for p in lobby.players:
		send_to_player(p, lobby_info)

func send_to_player(user_id, data):
	peer.get_peer(user_id).put_packet(JSON.stringify(data).to_utf8_buffer())

func generate_lobby_id():
	var result = ""
	# I decreased this range for convenience, can always increase
	for i in range(8):
		var index = randi() % characters.length()
		result += characters[index]
	return result

func change_character_color(user_id, lobby_id, color):
	if lobby_id in lobbies:
		lobbies[lobby_id].change_color(user_id, color)
	
	for p in lobbies[lobby_id].players:
		var player_info = {
			"id": user_id,
			"message": Message.COLOR,
			"lobby_id": lobby_id,
			"player": JSON.stringify(lobbies[lobby_id].players[user_id]),
			"host": lobbies[lobby_id].host_id
		}
		send_to_player(p, player_info)

func peer_connected(id):
	print("peer connected: %s" % str(id))
	users[id] = {
		"id": id,
		"message": Message.ID
	}
	send_to_player(id, users[id])

func peer_disconnected(id):
	users.erase(id)
	print("peer disconnected: %s" % str(id))
	pass

# ----------------------------------
# These are for the test WebRTC scene
func _on_start_server_button_down():
	start_server(host_port)

func _on_test_2_button_down():
	var message = {
		"message": Message.JOIN,
		"data": 'test'
	}
	var messageBytes = JSON.stringify(message).to_utf8_buffer()
	peer.put_packet(messageBytes)
# -------------------------------------
