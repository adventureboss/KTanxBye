class_name Bot extends Tank

@onready var tank_targets: Array[Node] = []
@onready var consumable_targets: Array[Node] = []
@onready var focused_tank: Tank = null
@onready var focused_food: Node = null
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@onready var tank_in_range: bool = false
@onready var food_in_range: bool = false

func allow_instantiation():
	pass

func _ready():
	super()

	if multiplayer.get_unique_id() != get_tank_authority():
		return
	
	tank_targets = get_tree().get_nodes_in_group("Tanks")
	consumable_targets = get_tree().get_nodes_in_group("consumables")

	emote = emote.instantiate()
	emote.tank_id = tank_id
	add_child(emote)
	
	_change_tank_target()

func _process(delta):
	super(delta)

func get_tank_authority():
	return GameManager.player_host
	
func _move(delta, direction):
	#direction = to_local(nav_agent.get_next_path_position()).normalized()
	var target_velocity = direction * MAX_SPEED

	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	
	move_and_slide()

func _change_target(targets: Array[Node]):
	if targets.size() <= 0:
		return
	var shortest_distance = INF
	var nearest_target = null

	for t in targets:
		if t == self:
			continue
		var distance = position.distance_to(t.position)  # Calculate distance to player
		if distance < shortest_distance:  # If this player is closer
			shortest_distance = distance  # Update shortest distance
			nearest_target = t  # Update nearest player

	return [nearest_target, shortest_distance]

func _change_tank_target():
	var target_return = _change_target(tank_targets)
	focused_tank = target_return[0]  # Set the nearest player as the new target
	if target_return[1] < 700:
		tank_in_range = true
	else:
		tank_in_range = false

func _change_consumable_target():
	consumable_targets = get_tree().get_nodes_in_group("consumables")
	var target_return = _change_target(consumable_targets)
	focused_food = target_return[0]
	# add a clause here to determine different distances/benefit for items
	if target_return[1] < 500:
		food_in_range = true
	else:
		food_in_range = false

func _on_tank_sense_area_2d_area_entered(area):
	_change_tank_target()

func _on_tank_sense_area_2d_area_exited(area):
	_change_tank_target()

func _update_path():
	# TODO add another timer so the bot doesn't switch targets all the time
	if randf_range(0,1) < .15 and focused_food != null and food_in_range:
		nav_agent.target_position = focused_food.global_position
	elif focused_tank != null:
		print(focused_tank.global_position)
		nav_agent.target_position = focused_tank.global_position

func _on_path_timer_timeout():
	_update_path()

func get_movement_vector():
	return to_local(nav_agent.get_next_path_position())

func _on_bullet_sense_area_2d_body_entered(body):
	if body.projectile_owner == self:
		# don't be scared!
		return
	if can_boost:
		# let's make it a chance to see if they do dodge
		if randf_range(0, 1) < 0.9:
			return
		var bullet_direction = body.direction
		var dodge_direction = Vector2(bullet_direction.y, -bullet_direction.x).normalized()

		# random orthogonal vector
		if randf_range(0, 1) < 0.5:
			dodge_direction = -dodge_direction
		
		apply_boost(dodge_direction * 4.5)
		can_boost = false
		boost_timer.start()

func apply_boost(direction: Vector2):
	var boost_strength = 2500.0
	velocity += direction * boost_strength

func control_barrel():
	var mouse_position = focused_tank.global_position
	barrel_tip.look_at(mouse_position)
	
	if tank_in_range && process_mode == Node.PROCESS_MODE_INHERIT:
		if !barrel_tip.fire_wait:
			barrel_tip._fire.rpc()

func _on_consumable_sense_area_2d_area_entered(area):
	_change_consumable_target()

func _on_consumable_sense_area_2d_area_exited(area):
	_change_consumable_target()

func _on_health_component_died(id, enemy_id):
	# stop shooting
	process_mode = Node.PROCESS_MODE_DISABLED
	pass

func _on_respawn_timer_timeout():
	process_mode = Node.PROCESS_MODE_INHERIT
	_change_tank_target()
	pass

@rpc("any_peer", "call_local")
func update_health_display():
	super()
	
	_change_tank_target()

func on_health_changed():
	super()

func _on_boost_timer_timeout():
	super()

@rpc("any_peer", "call_local")
func show_emote_sprite(id, path):
	super(id, path)
