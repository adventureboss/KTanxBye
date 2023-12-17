extends Control

@export var color_field: OptionButton

@onready var start_button: Button = $Start
@onready var color_button: OptionButton = $Elements/ColorButton

var player_slots: Array[Node]

signal start_pressed()
signal color_changed(color)

func _ready():
	# get multiplayer manager and subscribe it
	start_pressed.connect(get_node("../../MultiplayerManager").on_start_pressed)
	color_changed.connect(get_node("../../MultiplayerManager").on_color_changed)
	if multiplayer.get_unique_id() != 1:
		start_button.visible = false
	start_button.set_disabled(true)
	
	player_slots = get_tree().get_nodes_in_group("PlayerSlots")

func load_player_into_lobby(id, player_name, player_color):
	if multiplayer.get_unique_id() == id:
		for i in color_button.get_item_count():
			if color_button.get_item_text(i).to_lower() == player_color:
				color_button.select(i)
				break
	
	if multiplayer.get_unique_id() != 1:
		return
	
	for slot in player_slots:
		if slot.text.begins_with("Waiting"):
			# using edit_description to keep multiplayerSynchronizer configured
			slot.editor_description = str(id)
			slot.text = "%s : %s" % [player_name, player_color]
			break

func update_player_in_lobby(id, player_name, player_color):
	if multiplayer.get_unique_id() != 1:
		return

	for slot in player_slots:
		if slot.editor_description == str(id):
			slot.text = "%s : %s" % [player_name, player_color]
			print(slot.text)
			break

func _on_start_pressed():
	start_pressed.emit()

func _on_color_button_item_selected(index):
	_collect_preferences(index)
	start_button.set_disabled(false)

func _collect_preferences(index):
	print("collecting color preference")
	var color
	if index == -1: # they somehow didn't select anything
		print("user didnt select")
		color = "blue"
	else:
		color = color_field.get_item_text(index)
	
	color_changed.emit(color)
