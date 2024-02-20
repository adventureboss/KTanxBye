class_name Bot extends Tank

@onready var tank_targets: Array[Node] = []
@onready var focused_tank: Tank = null
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func allow_instantiation():
	pass

func _ready():
	super()

	if multiplayer.get_unique_id() != get_tank_authority():
		return
	
	tank_targets = get_tree().get_nodes_in_group("Tanks")

	emote = emote.instantiate()
	emote.tank_id = tank_id
	add_child(emote)
	
	_change_target()

func _process(delta):
	super(delta)

func get_tank_authority():
	return GameManager.player_host
	
func _move(delta, direction):
	#if Input.is_action_pressed("boost") and can_boost:
		#apply_boost(direction)
		#can_boost = false
		#boost_timer.start()
	#print("direction %d %d" % direction)
	direction = to_local(nav_agent.get_next_path_position()).normalized()
	var target_velocity = direction * MAX_SPEED

	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	
	move_and_slide()

func _change_target():
	if tank_targets.size() <= 0:
		return
	var shortest_distance = INF
	var nearest_target = null

	for t in tank_targets:  # Loop through each player
		if t.get_tank_id() == get_tank_id():
			continue
		var distance = position.distance_to(t.position)  # Calculate distance to player
		if distance < shortest_distance:  # If this player is closer
			shortest_distance = distance  # Update shortest distance
			nearest_target = t  # Update nearest player

	focused_tank = nearest_target  # Set the nearest player as the new target

func _update_path():
	if focused_tank != null:
		nav_agent.target_position = focused_tank.global_position

func _on_path_timer_timeout():
	_update_path()

func get_movement_vector():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	return Vector2(x_movement, y_movement)

func apply_boost(direction: Vector2):
	var boost_strength = 2500.0
	velocity += direction * boost_strength

@rpc("any_peer", "call_local")
func update_health_display():
	super()

func on_health_changed():
	super()

func _on_boost_timer_timeout():
	super()

@rpc("any_peer", "call_local")
func show_emote_sprite(id, path):
	emote.start_emote(id, path)
