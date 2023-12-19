extends Control

@onready var grid: GridContainer = $ScrollContainer/GridContainer
@onready var entry: PackedScene = preload("res://scenes/game_object/ui/entry.tscn")

func _process(_delta):
	if Input.is_action_just_pressed("scoreboard"):
		show_scoreboard()
		print("show")
	elif Input.is_action_just_released("scoreboard"):
		hide_scoreboard()

# This could be smarter,
# i.e. searching, updating dynamically, sorting
func show_scoreboard():
	for e in grid.get_children():
		grid.remove_child(e)
		e.queue_free()

	var cells = ["Tag", "Kills", "Deaths", "Assists"]
	for p in GameManager.players:
		cells.append(GameManager.players[p].name)
		cells.append(str(GameManager.players[p].score.kills))
		cells.append(str(GameManager.players[p].score.deaths))
		cells.append(str(GameManager.players[p].score.assists))
	
	for cell in cells:
		var entry = entry.instantiate()
		entry.text = cell
		grid.add_child(entry)
	
	set_visible(true)

func hide_scoreboard():
	set_visible(false)
