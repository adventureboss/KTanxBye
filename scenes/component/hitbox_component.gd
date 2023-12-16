extends Area2D
class_name HitboxComponent

@export var speed : int = 500
@export var damage : int = 10
@export var max_range : int = 150 # need to just remove the projectiles when they go off camera
@export var fire_delay : float = 0.1
@export var direction : Vector2 = Vector2.RIGHT

@onready var ammo_sprite : Sprite2D = $Sprite2D


	
func _physics_process(delta):
	position += transform.x * speed * delta
	
func _on_StandardAmmo_body_entered(body):
	if body.is_in_group("player"):
		body.queue_free()
	queue_free()
