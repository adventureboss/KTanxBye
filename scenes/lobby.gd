extends Control

@export var color_field: OptionButton
@export var name_field: LineEdit

@onready var start_button: Button = $Start
@onready var ready_button: Button = $Ready

signal start_pressed(name, color)
signal ready_pressed(name, color)

func _ready():
	# get multiplayer manager and subscribe
	start_pressed.connect(get_node("../../MultiplayerManager").on_start_pressed)
	ready_pressed.connect(get_node("../../MultiplayerManager").on_ready_pressed)
	if multiplayer.get_unique_id() != 1:
		start_button.visible = false
	start_button.set_disabled(true)

func _on_start_pressed():
	start_pressed.emit()

func _on_ready_pressed():
	_collect_preferences()
	start_button.set_disabled(false)

# When one user presses a button,
# we want that data to be sent to all of the peers
# Calling this in the multiplayer_manager.gd
#func press_start():
	#_collect_preferences()

@rpc("any_peer", "call_local")
func _collect_preferences():
	print("collect preferences")
	var color
	var selected_id = color_field.get_selected_id()
	if selected_id == -1: # they somehow didn't
		print("user didnt select")
		color = "blue"
	else:
		color = color_field.get_item_text(selected_id)
	
	ready_pressed.emit(name_field.text, color)
