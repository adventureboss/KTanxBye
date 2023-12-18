extends Area2D
class_name HitboxComponent

@export var speed : int = 500
@export var damage : int = 10
@export var max_range : int = 150 # need to just remove the projectiles when they go off camera
@export var fire_delay : float = 0.1
@export var direction : Vector2 = Vector2.RIGHT

@onready var ammo_sprite : Sprite2D = $Sprite2D
@onready var animation_player : AnimationPlayer = null
@onready var std_ammo_sounds = $std_ammo_sound
var projectile_owner

func _ready():
	if find_child("AnimationPlayer"):
		animation_player = $AnimationPlayer
		std_ammo_sounds.play()
		animation_player.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	position += transform.x * speed * delta

@rpc("call_local", "any_peer")
func dead(id):
	if multiplayer.get_unique_id() != id:
		return

	speed = 0
	if animation_player:
		animation_player.play("explode")

func _on_animation_finished(anim_name):
	queue_free()
