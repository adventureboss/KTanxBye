extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $EmoteTimer

var player_id

func _enter_tree():
	set_multiplayer_authority(player_id)

@rpc("any_peer", "call_local")
func start_emote(path):
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		print("did not equal auth; %d, %d" % [get_multiplayer_authority(), multiplayer.get_unique_id()])
		return
	sprite.texture = load(path)
	visible = true
	timer.start()

func _on_emote_timer_timeout():
	visible = false
