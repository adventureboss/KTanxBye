extends Node2D

@export var player: Player
@export var camera: Camera2D
@onready var pointer = $Pointer
@onready var player_name = $Pointer/NameMarker
var disabled = false

func _ready():
	#if player_id == GameManager.ENVIRONMENT:
		#disable()
	pass

func enable(id, name):
	player_name.text = name
	
func disable():
	disabled = false
	set_process(false)
	visible = false

# base from this tutorial
# https://youtu.be/Sw9Iiejkae4?si=VPpL7UNA6UTAvfOl
func _physics_process(delta):
	if disabled:
		return
	var canvas = get_canvas_transform()
	# canvas.get_scale() for adjusting these for camera zoom
	var top_left = -camera.get_screen_center_position() / canvas.get_scale()
	var size = get_viewport_rect().size / canvas.get_scale()
	
	set_marker_position(Rect2(top_left, size))
	set_marker_rotation()

func set_marker_position(bounds : Rect2):
	pointer.global_position.x = clamp(global_position.x, bounds.position.x, bounds.end.x)
	pointer.global_position.y = clamp(global_position.y, bounds.position.y, bounds.end.y)

	# object is on screen
	if bounds.has_point(global_position):
		hide()
		return
	show()

func set_marker_rotation():
	var angle = (global_position - pointer.global_position).angle()
	pointer.global_rotation = angle
	player_name.rotation = 0.0
