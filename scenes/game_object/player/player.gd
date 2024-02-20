class_name Player extends Tank

@export var boost_available: TextureRect
@export var boost_unavailable: TextureRect
@export var emote_wheel: Control

func allow_instantiation():
	pass
	
func _ready():
	super()
	
	if multiplayer.get_unique_id() != tank_id:
		boost_available.visible = false
		boost_unavailable.visible = false
	emote = emote.instantiate()
	emote.tank_id = tank_id
	add_child(emote)
	emote_wheel.tank_id_what = tank_id

func _process(delta):
	super(delta)
	if multiplayer.get_unique_id() != tank_id:
		return
	
func _move(delta, direction):
	if multiplayer.get_unique_id() != tank_id:
		return
	if Input.is_action_pressed("boost") and can_boost:
		apply_boost(direction)
		can_boost = false
		boost_timer.start()
		boost_available.visible = false
		boost_unavailable.visible = true
	
	move_and_slide()

func get_movement_vector():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	return Vector2(x_movement, y_movement)

func apply_boost(direction: Vector2):
	print(direction)
	var boost_strength = 2500.0
	velocity += direction * boost_strength

func control_barrel():
	var mouse_position = get_global_mouse_position()
	barrel_tip.look_at(mouse_position)
	
	if Input.is_action_pressed("fire_primary") and process_mode == Node.PROCESS_MODE_INHERIT:
		if !barrel_tip.fire_wait:
			barrel_tip._fire.rpc()

@rpc("any_peer", "call_local")
func update_health_display():
	super()

func on_health_changed():
	super()

func _on_boost_timer_timeout():
	if super():
		boost_available.visible = true
		boost_unavailable.visible = false

@rpc("any_peer", "call_local")
func show_emote_sprite(id, path):
	super(id, path)
