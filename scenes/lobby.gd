extends Control

@export var color_field: OptionButton

@onready var start_button: Button = $Start
@onready var color_button: OptionButton = $Elements/ColorButton

var player_slots: Array[Node]

signal start_pressed()
signal color_changed(color)

func _ready():
	# get multiplayer manager and subscribe it
	start_pressed.connect(get_node("../../Client").on_start_pressed)
	color_changed.connect(get_node("../../Client").on_color_changed)
	if multiplayer.get_unique_id() != GameManager.player_host:
		start_button.visible = false
	
	player_slots = get_tree().get_nodes_in_group("PlayerSlots")

func load_players_into_lobby(players):
	# find new players
	for p in players:
		for slot in player_slots:
			if str(players[p].index) == slot.name and slot.text.begins_with("Waiting"):
				# the slot has not been loaded
				load_player_into_lobby(players[p].id, players[p].name, players[p].color, players[p].index)
				break

func load_player_into_lobby(id, player_name, player_color, slot_index):
	if multiplayer.get_unique_id() == id:
		for i in color_button.get_item_count():
			if color_button.get_item_text(i) == player_color:
				color_button.select(i)
				break
	
	var slot = player_slots[slot_index-1]
	if slot.text.begins_with("Waiting"):
		# using edit_description to keep multiplayerSynchronizer configured
		slot.editor_description = str(id)
		slot.text = "%s : %s" % [player_name, player_color]

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
