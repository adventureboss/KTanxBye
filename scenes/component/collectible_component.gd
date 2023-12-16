extends Area2D
class_name Collectible

@export var ability_id : int = 0

@onready var collision_shape_2d : CollisionShape2D = $CollisionShape2D
@onready var sprite_2d : Sprite2D = $Sprite2D


func _ready():
	body_entered.connect(on_body_entered)
	
func collect(body):
	GameEvents.emit_ability_pick_up(GameManager.abilities[ability_id], GameManager.players[body.to_int()].id)
	queue_free()
	
func disable_collision():
	collision_shape_2d.disabled = true

func on_body_entered(body):
	collect(body.name)
