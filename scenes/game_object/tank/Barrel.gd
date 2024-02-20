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
@onready var world = get_tree().get_first_node_in_group("world")

var fire_wait : bool = false
var bullets_fired = 0
var current_ammo_bullets_fired = 0
var tank_color
var parent_id = null
var parent : Tank = null
var is_bot = false

func _ready():
	parent = get_parent()
	parent_id = parent.name.to_int()
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_pick_up.connect(update_ammo)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	tank_color = GameManager.tanks[parent_id].color
	is_bot = GameManager.tanks[parent_id].bot

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if multiplayer.get_unique_id() != parent.get_tank_authority():
		return
	
	parent.control_barrel()

@rpc("any_peer", "call_local")
func _fire():
	fire_wait = true
	var bullet_name = current_ammo.name
	var new_bullet
	if bullet_name == "spread":
		for n in spread_arch.get_children():
			new_bullet = load(current_ammo.path).instantiate()
			var bullet_sprite = new_bullet.find_child("Sprite2D")
			bullet_sprite.scale = Vector2(0.35, 0.35)
			bullet_sprite.texture = load(bullet_manager.bullet_sprites[tank_color][new_bullet.bullet_name])
			new_bullet.projectile_owner = owner
			timer.wait_time = new_bullet.fire_delay
			world.add_child(new_bullet)
			new_bullet.global_position = fire_direction.global_position
			new_bullet.global_transform = n.global_transform
	else:
		new_bullet = load(current_ammo.path).instantiate()
		var bullet_sprite = new_bullet.find_child("Sprite2D")
		bullet_sprite.texture = load(bullet_manager.bullet_sprites[tank_color][new_bullet.bullet_name])
		if bullet_name == "rapid_fire":
			bullet_sprite.scale = Vector2(0.35, 0.35)
		new_bullet.projectile_owner = owner
		timer.wait_time = new_bullet.fire_delay
		world.add_child(new_bullet)
		new_bullet.global_transform = fire_direction.global_transform
		
	timer.start()
	bullets_fired += 1
	current_ammo_bullets_fired += 1
	if  current_ammo_bullets_fired >= new_bullet.max_shots:
		update_ammo(GameManager.abilities[0], parent_id, null )

func on_timer_timeout():
	fire_wait = false

func update_ammo(ability, id, _position):
	current_ammo_bullets_fired = 0
	ammo_change_broadcast.rpc(ability, id)
	
@rpc("any_peer", "call_local")
func ammo_change_broadcast(ammo, id):
	if parent_id == id:
		current_ammo = ammo
	
