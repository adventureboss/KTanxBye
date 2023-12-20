class_name Lobby extends RefCounted
# this will make a smaller object than Node

var host_id: int
var players: Dictionary = {}

func _init(id):
	host_id = id

func add_player(id, name, color="Blue", score={"kills": 0, "deaths": 0, "assists": 0}):
	players[id] = {
		"id": id,
		"name": name,
		"color": color,
		"score": score,
		"index": players.size() + 1
	}
	return players[id]
