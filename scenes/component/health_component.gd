extends Node
class_name HealthComponent

signal died(id, enemy_id)
signal health_changed

@export var max_health: float = 100
var current_health


func _ready():
	current_health = max_health

@rpc("any_peer", "call_local")
func damage(id, enemy_id, damage_amount: float):
	current_health = max(current_health - damage_amount, 0)
	health_changed.emit()
	Callable(check_death).call_deferred(id, enemy_id)

func get_health_percent():
	if max_health <= 0:
		return 0
	return min(current_health / max_health, 1)

func check_death(id, enemy_id):
	if current_health == 0:
		died.emit(id, enemy_id)
		owner.queue_free()
