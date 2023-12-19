extends Area2D
class_name HurtboxComponent

@export var health_component: Node

func _ready():
	owner = get_parent()
	area_entered.connect(on_area_entered)
	
func on_area_entered(other_area: Area2D):
	if not other_area is HitboxComponent:
		return
	
	# keeps you from killing yourself with your own bullets
	if other_area.projectile_owner == owner:
		return
	
	if health_component == null:
		return
	
	var hitbox_component = other_area as HitboxComponent
	var player_hit = owner.name.to_int()
	var player_hit_by = hitbox_component.projectile_owner.name.to_int()
	
	# this here will get called in all peers
	health_component.damage.rpc(player_hit, player_hit_by, hitbox_component.damage)
	hitbox_component.dead.rpc(player_hit)
