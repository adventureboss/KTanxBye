extends Node2D
class_name EnvironmentalComponent

@onready var projectile_owner = 10101010
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@export var damage = 10

@rpc("any_peer", "call_local")
func dead(id):
	if animation_player:
		animation_player.play("explode")

func _on_animation_finished(anim_name):
	queue_free()
