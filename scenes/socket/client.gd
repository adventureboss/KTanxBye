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

@export var multiplayer_manager: MultiplayerManager
@export var scene_manager: Node2D
@export var name_field : LineEdit
@export var join_field : LineEdit
var lobby_scene: Control

# free stun server provided by google (temporary)
@export var stun_server: String = "stun:stun1.l.google.com:19302"

@onready var peer = WebSocketMultiplayerPeer.new() # for connecting the users to each other
@onready var rtc_peer: WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new() # for sending real data

var host: bool = false
var in_lobby: bool = false

var id: int = 0
var host_id: int
var lobby_id = ""
var lobby = {}

func _ready():
	multiplayer.connected_to_server.connect(rtc_server_connnected)
	multiplayer.peer_connected.connect(rtc_peer_connnected)
	multiplayer.peer_disconnected.connect(rtc_peer_disconnnected)

func rtc_server_connnected():
	print("rtc server connected")

func rtc_peer_connnected(id):
	print("rtc peer connected; id %d" % id)

func rtc_peer_disconnnected(id):
	print("rtc peer disconnected; id %d" % id)

func _process(_delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_utf8()
			var data = JSON.parse_string(dataString)
			print(data)
			if data.message == Message.ID:
				id = data.id
				connected(id)
				if host:
					_send_lobby_message()
				else:
					# text field checked for empty on clicking button
					_send_lobby_message(join_field.text)
			if data.message == Message.USER_CONNECTED:
				create_peer(data.id)
			if data.message == Message.LOBBY:
				lobby_id = data.lobby_id
				host_id = data.host
				GameManager.player_host = host_id
				lobby = Lobby.new(host_id)
				lobby.players = JSON.parse_string(data.players)
				if !in_lobby:
					_load_lobby()
				# now, each time players is updated
				load_players_into_lobby(lobby.players)
			if data.message == Message.COLOR:
				var updated_player = JSON.parse_string(data.player)
				lobby.update_player(data.id, updated_player)
			if data.message == Message.CANDIDATE:
				if rtc_peer.has_peer(data.original_peer):
					print("got candidate: original peer %s; my id %s" % [str(data.original_peer), str(id)])
					rtc_peer.get_peer(data.original_peer).connection.add_ice_candidate(data.mid, data.index, data.sdp)
			if data.message == Message.OFFER:
				print("offer; original peer %d" % data.original_peer)
				if rtc_peer.has_peer(data.original_peer):
					rtc_peer.get_peer(data.original_peer).connection.set_remote_description("offer", data.data)
			if data.message == Message.ANSWER:
				print("answer; original peer %d" % data.original_peer)
				if rtc_peer.has_peer(data.original_peer):
					rtc_peer.get_peer(data.original_peer).connection.set_remote_description("answer", data.data)
			# good lord

# hooks up rpc calls
func connected(peer_id):
	rtc_peer.create_mesh(peer_id)
	multiplayer.multiplayer_peer = rtc_peer

func connect_to_server():
	#peer.create_client("ws://139.144.56.116:8915")
	peer.create_client("ws://127.0.0.1:8915")
	print("started client")

# WebRTC Connection
func create_peer(id):
	if id != self.id:
		var peer : WebRTCPeerConnection = WebRTCPeerConnection.new()
		peer.initialize({
			"iceServers" : [{ "urls": ["stun:stun.l.google.com:19302"] }]
		})
		print("binding id " + str(id) + "my id is " + str(self.id))
		
		peer.session_description_created.connect(self.offer_created.bind(id))
		peer.ice_candidate_created.connect(self.ice_candidate_created.bind(id))
		rtc_peer.add_peer(peer, id)
		
		if id < rtc_peer.get_unique_id(): # this is a strange expression, but its to decide order
			peer.create_offer()

func offer_created(type, data, peer_id):
	if !rtc_peer.has_peer(peer_id):
		print("offer not created")
		return
	
	# create a local description, becomes a peers remote_description
	rtc_peer.get_peer(peer_id).connection.set_local_description(type, data)
	
	if type == "offer":
		send_offer(peer_id, data)
	else:
		# type must be answer
		send_answer(peer_id, data)

func send_offer(id, data):
	var message = {
		"peer" : id,
		"original_peer" : self.id,
		"message" : Message.OFFER,
		"data": data,
		"lobby_id": lobby_id
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	pass

func send_answer(id, data):
	var message = {
		"peer" : id,
		"original_peer" : self.id,
		"message" : Message.ANSWER,
		"data": data,
		"lobby_id": lobby_id
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	pass

func ice_candidate_created(midName, indexName, sdpName, id):
	var message = {
		"peer" : id,
		"original_peer" : self.id,
		"message" : Message.CANDIDATE,
		"mid": midName,
		"index": indexName,
		"sdp": sdpName,
		"lobby_id": lobby_id
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	pass

func _on_join_pressed():
	if !_check_name_field():
		# should signal something here.
		return
	if join_field.text == "":
		# should signal something here.
		print("empty join field")
		return
	connect_to_server()

func _on_host_pressed():
	if !_check_name_field():
		print("empty name field")
		# should signal something here.
		return
	host = true
	connect_to_server()
	
func _check_name_field():
	if name_field == null:
		print("set the name_field dummy")
		return false
	var tag = name_field.text
	if tag == "":
		# let's not let it be empty, don't want any weird bugs
		print("denying blank battle tag")
		return false
	return true

func _send_lobby_message(lobby_id=""):
	var message = {
		"id": id,
		"lobby_id": lobby_id,
		"message": Message.LOBBY,
		"name": name_field.text
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func _load_lobby():
	scene_manager.load_lobby()
	in_lobby = true

func load_players_into_lobby(players):
	if lobby_scene == null:
		lobby_scene = scene_manager.get_node("Lobby")
	lobby_scene.load_players_into_lobby(players)

func on_color_changed(player_color):
	print("on_color_changed" + player_color)
	var message = {
		"id": id,
		"message": Message.COLOR,
		"lobby_id": lobby_id,
		"color": player_color,
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func on_start_pressed():
	if lobby_id == "":
		return
	multiplayer_manager.receive_players.rpc(lobby.players)
	multiplayer_manager.start_game.rpc()

# ------------------------------------------------
# the following tests are for the webrtc test scene
@rpc("any_peer")
func ping():
	print("ping from %s" % str(multiplayer.get_remote_sender_id()))

func _on_test_button_down():
	ping.rpc()

func _on_start_client_button_down():
	connect_to_server()

func _on_lobby_button_down():
	var message = {
		"id": id,
		"message": Message.LOBBY,
		"lobby_id": $LobbyVal.text,
		"name": ""
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

func _on_start_game_button_down():
	if lobby_id == "":
		return
	var message = {
		"id": id,
		"message": Message.START,
		"lobby_id": lobby_id,
		"host_id": host_id
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
# ---------------------------------------
