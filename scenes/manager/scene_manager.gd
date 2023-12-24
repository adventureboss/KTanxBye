extends Node

@export var scene_prefix: String = "res://scenes/%s.tscn"
@export var start = "start"
@export var lobby = "lobby"
@export var world = "world"
var current = null
var scene_manager = null
@export var multiplayer_manager: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	scene_manager = get_node(".")
	current = get_child(0)
	# not sure of a better spot for this, making the mouse unable to leave
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		# sets the mouse free
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.mouse_mode != Input.MOUSE_MODE_CONFINED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func unload_scene():
	if is_instance_valid(current):
		current.queue_free()
	current = null

func load_scene(scene_name: String):
	unload_scene()
	var path = scene_prefix % scene_name
	var resource = load(path)
	if resource:
		current = resource.instantiate()
		scene_manager.add_child(current)

func load_world():
	load_scene(world)

func load_lobby():
	load_scene(lobby)
	# going to connect the lobby here
	multiplayer_manager.load_player_into_lobby.connect(current.load_player_into_lobby)
	multiplayer_manager.update_player_in_lobby.connect(current.update_player_in_lobby)
