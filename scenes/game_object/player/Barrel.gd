extends Marker2D

@export var current_ammo : Dictionary = GameManager.abilities[0]
@onready var ammo_name : String = "standard"
@onready var ray_cast : RayCast2D = $RayCast2D
@onready var fire_direction : Marker2D = $FireDirection
@onready var timer : Timer = $Timer
@onready var barrel_sprite : Sprite2D = $Sprite2D
@onready var spread_arch : Node2D = $SpreadArch
@onready var multiplayer_synchronizer : MultiplayerSynchronizer = get_parent().find_child("MultiplayerSynchronizer")
@onready var bullet_manager : BulletManager = get_tree().get_first_node_in_group("BulletManager")

var fire_wait : bool = false
var bullets_fired = 0
var tank_color

func _ready():
	var parent_id = get_parent().name.to_int()
	set_multiplayer_authority(parent_id)
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_pick_up.connect(update_ammo)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	tank_color = GameManager.players[parent_id].color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if multiplayer_synchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return

	var mouse_position = get_global_mouse_position()
	look_at(mouse_position)
	
	if Input.is_action_pressed("fire_primary") and get_parent().process_mode == Node.PROCESS_MODE_INHERIT:
		if !fire_wait:
			_fire.rpc()

@rpc("authority", "call_local")
func _fire():
	var auth = get_multiplayer_authority()
	fire_wait = true
	var bullet_name = current_ammo.name
	if bullet_name == "spread":
		for n in spread_arch.get_children():
			var new_bullet = load(current_ammo.path).instantiate()
			var bullet_sprite = new_bullet.find_child("Sprite2D")
			bullet_sprite.scale = Vector2(0.35, 0.35)
			bullet_sprite.texture = load(bullet_manager.bullet_sprites[tank_color][new_bullet.bullet_name])
			new_bullet.projectile_owner = owner
			timer.wait_time = new_bullet.fire_delay
			bullet_manager.add_child(new_bullet)
			new_bullet.global_position = fire_direction.global_position
			new_bullet.global_transform = n.global_transform
	else:
		var new_bullet = load(current_ammo.path).instantiate()
		var bullet_sprite = new_bullet.find_child("Sprite2D")
		bullet_sprite.texture = load(bullet_manager.bullet_sprites[tank_color][new_bullet.bullet_name])
		if bullet_name == "rapid_fire":
			bullet_sprite.scale = Vector2(0.35, 0.35)
		new_bullet.projectile_owner = owner
		timer.wait_time = new_bullet.fire_delay
		bullet_manager.add_child(new_bullet)
		new_bullet.global_transform = fire_direction.global_transform
		
	timer.start()
	bullets_fired += 1

func on_timer_timeout():
	fire_wait = false

func update_ammo(ability, id, _position):
	if id != multiplayer.get_unique_id():
		return
	
	current_ammo = ability
