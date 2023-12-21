extends CharacterBody2D
class_name Ammo

@export var speed : int = 500
@export var damage : int = 10
@export var max_range : int = 150 # need to just remove the projectiles when they go off camera
@export var fire_delay : float = 0.1
@export var max_shots : int = 999999 # 999999 equals infinite ammo
@export var direction : Vector2 = Vector2.RIGHT
@export var bullet_name : String = "standard"

@onready var ammo_sprite : Sprite2D = $Sprite2D
@onready var animation_player : AnimationPlayer = null

var projectile_owner

func _ready():
	var bullet_manager = get_tree().get_first_node_in_group("BulletManager")
	if find_child("AnimationPlayer"):
		animation_player = $AnimationPlayer
		animation_player.animation_finished.connect(_on_animation_finished)

		bullet_manager.play()

func _physics_process(delta):
	velocity = transform.x * speed * delta
	var collision = move_and_collide(velocity)
	if collision != null:
		dead(GameManager.ENVIRONMENT)

@rpc("any_peer", "call_local")
func dead(id):
	speed = 0
	if animation_player:
		animation_player.play("explode")

func _on_animation_finished(anim_name):
	queue_free()
