extends Node

enum Message {
	id,
	join,
	userConnected,
	userDisconnected,
	lobby,
	candidate,
	offer,
	answer,
	checkIn
}

# free stun server provided by google (temporary)
@export var stun_server: String = "stun:stun1.l.google.com:19302"

var peer = WebSocketMultiplayerPeer.new() # for connecting the users to each other
var rtc_peer: WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new() # for sending real data

var id = 0
var lobby_id = ""
var host_id: int

func _ready():
	multiplayer.connected_to_server.connect(rtc_server_connnected)
	multiplayer.peer_connected.connect(rtc_peer_connnected)
	multiplayer.peer_disconnected.connect(rtc_peer_disconnnected)

func rtc_server_connnected():
	print("rtc server connected")

func rtc_peer_connnected():
	print("rtc peer connected; id %d" % id)

func rtc_peer_disconnnected():
	print("rtc peer disconnected; id %d" % id)

func _process(_delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_utf8()
			var data = JSON.parse_string(dataString)
			print(data)
			if data.message == Message.id:
				id = data.id
				connected(id)
			if data.message == Message.userConnected:
				create_peer(data.id)
			if data.message == Message.lobby:
				GameManager.players = JSON.parse_string(data.players)
				lobby_id = data.lobby_id
				host_id = data.host
			if data.message == Message.candidate:
				var peers = rtc_peer.get_peers()
				print("peers")
				print(peers)
				if rtc_peer.has_peer(data.original_peer):
					print("got candidate: original peer %s; my id %s" % [str(data.original_peer), str(id)])
					rtc_peer.get_peer(data.original_peer).connection.add_ice_candidate(data.mid, data.index, data.sdp)
			if data.message == Message.offer:
				print("offer; original peer %d" % data.original_peer)
				if rtc_peer.has_peer(data.original_peer):
					rtc_peer.get_peer(data.original_peer).connection.set_remote_description("offer", data.data)
			if data.message == Message.answer:
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
#func create_peer(peer_id):
	#if peer_id != id:
		#var peer_connection : WebRTCPeerConnection = WebRTCPeerConnection.new()
		#var error = peer_connection.initialize({
			#"iceServers": [{"urls": [stun_server]}]
		#})
		#if error != Error.OK:
			#print("err initializing RTCPeerConnection %s" % str(error))
		#print("binding id %s, my id %s" % [peer_id, id])
		#
		#peer_connection.session_description_created.connect(self.offer_created.bind(peer_id))
		#peer_connection.ice_candidate_created.connect(self.ice_candidate_created.bind(peer_id))
		#rtc_peer.add_peer(peer_connection, peer_id)
		#
		#if peer_id < rtc_peer.get_unique_id(): 
			#peer_connection.create_offer()
func create_peer(id):
	if id != self.id:
		var peer : WebRTCPeerConnection = WebRTCPeerConnection.new()
		peer.initialize({
			"iceServers" : [{ "urls": [stun_server] }]
		})
		print("binding id " + str(id) + "my id is " + str(self.id))
		
		peer.session_description_created.connect(self.offer_created.bind(id))
		peer.ice_candidate_created.connect(self.ice_candidate_created.bind(id))
		var error = rtc_peer.add_peer(peer, id)
		if error != 0:
			print("error adding peer %d" % error)
		
		print("id and peer get_unqiue_id comp %d < %d" % [id, rtc_peer.get_unique_id()])
		print(rtc_peer.get_peers())
		#if host_id != self.id:
		if id != rtc_peer.get_unique_id():
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

func ice_candidate_created(mid_name, index_name, sdp_name, peer_id):
	var message = {
		"id": peer_id,
		"original_peer": self.id,
		"message": Message.candidate,
		"mid": mid_name,
		"index": index_name,
		"sdp": sdp_name,
		"lobby_id": lobby_id
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())


# here's my information
func send_offer(id, data):
	var message = {
		"id": id,
		"original_peer": self.id,
		"message": Message.offer,
		"data": data,
		"lobby_id": lobby_id
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

# response based on that information
func send_answer(id, data):
	var message = {
		"id": id,
		"original_peer": self.id,
		"message": Message.answer,
		"data": data,
		"lobby_id": lobby_id
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())

@rpc("any_peer", "call_local")
func ping():
	print("ping from %s" % str(multiplayer.get_remote_sender_id()))

func _on_test_button_down():
	ping.rpc()

func _on_start_client_button_down():
	connect_to_server()

func _on_lobby_button_down():
	var message = {
		"id": id,
		"message": Message.lobby,
		"lobby_id": $LobbyVal.text,
		"name": ""
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
