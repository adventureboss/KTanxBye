extends Node

@export var scene_prefix: String = "res://scenes/%s.tscn"
@export var start = "start"
@export var lobby = "lobby"
@export var world = "world"
var current = null
var scene_manager = null

# Called when the node enters the scene tree for the first time.
func _ready():
	scene_manager = get_node(".")
	current = get_child(0)

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
