extends Control

const folder_path = "res://assets/sprites/Emotes/%s"

@onready var player: Player = get_parent().get_parent().get_parent()

var player_id_what

func _process(_delta):
	if player_id_what != multiplayer.get_unique_id():
		return
	if Input.is_action_pressed("emote"):
		show_emote_wheel()
	else:
		hide_emote_wheel()

func show_emote_wheel():
	visible = true

func hide_emote_wheel():
	visible = false

func _on_pressed(index):
	var emote = GameManager.emotes[index]
	player.show_emote_sprite.rpc(player_id_what, folder_path % emote.asset)
	hide_emote_wheel()
