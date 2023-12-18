extends Node
class_name HealthComponent

signal died
signal health_changed

@export var max_health: float = 100
var current_health


func _ready():
	current_health = max_health

@rpc("any_peer", "call_local")
func damage(id, damage_amount: float):
	print("damage function %s, %s" % [id, multiplayer.get_unique_id()])
	if multiplayer.get_unique_id() != id:
		return
	print("changed current health")
	current_health = max(current_health - damage_amount, 0)
	health_changed.emit()
	Callable(check_death).call_deferred()


func get_health_percent():
	if max_health <= 0:
		return 0
	return min(current_health / max_health, 1)

func check_death():
	if current_health == 0:
		died.emit()
		owner.queue_free()
