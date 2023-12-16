extends Marker2D

@export var current_ammo : PackedScene = preload("res://scenes/ability/standard_ammo_ability/standard_ammo.tscn")
@onready var ammo_name : String = "standard"
@onready var ray_cast : RayCast2D = $RayCast2D
@onready var fire_direction : Marker2D = $FireDirection
@onready var timer : Timer = $Timer
@onready var barrel_sprite : Sprite2D = $Sprite2D
@onready var spread_arch : Node2D = $SpreadArch
@onready var multiplayer_synchronizer : MultiplayerSynchronizer = get_parent().find_child("MultiplayerSynchronizer")

var fire_wait : bool = false

func _ready():
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_pick_up.connect(update_ammo)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if multiplayer_synchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return

	if Input.is_action_pressed("fire_primary"):
		if !fire_wait:
			_fire()
		
func _fire():
	fire_wait = true
	if ammo_name == "spread":
		for n in spread_arch.get_children():
			var new_bullet = current_ammo.instantiate()
			new_bullet.projectile_owner = owner
			timer.wait_time = new_bullet.fire_delay
			add_child(new_bullet)
			new_bullet.global_position = fire_direction.global_position
			new_bullet.transform = n.global_transform
	else:
		var new_bullet = current_ammo.instantiate()
		new_bullet.projectile_owner = owner
		timer.wait_time = new_bullet.fire_delay
		add_child(new_bullet)
		new_bullet.transform = fire_direction.global_transform
	timer.start()

func on_timer_timeout():
	fire_wait = false

func update_ammo(ability, id):
	if id != multiplayer.get_unique_id():
		return

	if ability == "spread":
		current_ammo = preload("res://scenes/ability/standard_ammo_ability/standard_ammo.tscn")
		ammo_name = "spread"
		return
	ammo_name = "standard"
	current_ammo = load(ability)
