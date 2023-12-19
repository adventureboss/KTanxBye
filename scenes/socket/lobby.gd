class_name Lobby extends RefCounted
# this will make a smaller object than Node

var host_id: int
var players: Dictionary = {}

func _init(id):
	host_id = id

func add_player(id, name):
	players[id] = {
		"id": id,
		"name": name,
		"index": players.size() + 1
	}
	return players[id]
