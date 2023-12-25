extends Node

@onready var global: Camera2D = $GlobalCamera
var transitioning: bool = false

# Followed the following godot tutorial, 
# just had to update some things for Godot 4
# https://youtu.be/8Lj3pUYuVe8?si=vmxu315lzgY5llGu
func transition_camera(from: Camera2D, to:Camera2D, duration: float = 1.0):
	if transitioning:
		return
	global.zoom = from.zoom
	global.offset = from.offset
	global.light_mask = from.light_mask
	
	global.global_transform = from.global_transform
	
	# swap the cameras
	global.enabled = true
	global.make_current()
	transitioning = true
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(global, "global_transform", to.global_transform, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(global, "zoom", to.zoom, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(global, "offset", to.offset, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.play()
	
	await tween.finished
	
	# swap to second camera
	to.make_current()
	global.enabled = false
	transitioning = false
