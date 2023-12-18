extends Area2D
class_name HurtboxComponent

@export var health_component: Node


func _ready():
	area_entered.connect(on_area_entered)
	

func on_area_entered(other_area: Area2D):
	if not other_area is HitboxComponent:
		return
	
	if other_area.projectile_owner == owner:
		return
		
	if health_component == null:
		return
		
	var hitbox_component = other_area as HitboxComponent
	var hit_by = hitbox_component.projectile_owner.name.to_int()
	health_component.damage.rpc(multiplayer.get_unique_id(), hit_by, hitbox_component.damage)
	hitbox_component.dead.rpc(multiplayer.get_unique_id())
