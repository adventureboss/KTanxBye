extends RefCounted
class_name Lobby
# this will make a smaller object than Node

var host_id: int
var players: Dictionary = {}

func _init(id):
	host_id = id

# while in the lobby, this will keep track of our players.
# After that, copying the players to the GameManager we had previously
func add_player(id, name, color="Blue", score={"kills": 0, "deaths": 0, "assists": 0}):
	players[id] = {
		"id": id,
		"name": name,
		"color": color,
		"score": score,
		"index": players.size() + 1
	}
	return players[id]

func update_player(id, player):
	players[id] = {
		"id": player.id,
		"name": player.name,
		"color": player.color,
		"score": player.score,
		"index": player.index
	}
	return players[id]

func change_color(id, color):
	players[id] = {
		"id": id,
		"name": players[id].name,
		"color": color,
		"score": players[id].score,
		"index": players[id].index
	}
	return players[id]
