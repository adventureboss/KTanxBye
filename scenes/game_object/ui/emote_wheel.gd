extends Control

const folder_path = "res://assets/sprites/Emotes/%s"

@export var player: Player

func _enter_tree():
	set_multiplayer_authority(player.name.to_int())

func _process(_delta):
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
	player.show_emote_sprite.rpc(folder_path % emote.asset)
	hide_emote_wheel()
