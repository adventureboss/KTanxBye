extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $EmoteTimer

var tank_id

func start_emote(id, path):
	if id != tank_id:
		return
	sprite.texture = load(path)
	visible = true
	timer.start()

func _on_emote_timer_timeout():
	visible = false
