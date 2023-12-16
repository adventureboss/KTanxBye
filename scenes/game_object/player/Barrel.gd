extends Marker2D

@onready var current_ammo : PackedScene = preload("res://scenes/ability/standard_ammo_ability/standard_ammo.tscn")
@onready var ray_cast : RayCast2D = $RayCast2D
@onready var fire_direction : Marker2D = $FireDirection
@onready var timer : Timer = $Timer
@onready var barrel_sprite : Sprite2D = $Sprite2D

var fire_wait : bool = false

func _ready():
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_pick_up.connect(update_ammo)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_pressed("fire_primary"):
		if !fire_wait:
			_fire()
		
func _fire():
	fire_wait = true
	var ammo : HitboxComponent = current_ammo.instantiate()
	ammo.projectile_owner = owner
	timer.wait_time = ammo.fire_delay
	add_child(ammo)
	ammo.transform = fire_direction.global_transform
	timer.start()

func on_timer_timeout():
	fire_wait = false

func update_ammo(ability, id):
	print("updating ammo to id: " + str(id))
	current_ammo = load(ability)
