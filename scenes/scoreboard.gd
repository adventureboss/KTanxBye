extends Control

@onready var grid: GridContainer = $ScrollContainer/GridContainer
@onready var entry: PackedScene = preload("res://scenes/game_object/ui/entry.tscn")
@onready var refreshTimer: Timer = $RefreshTimer
@onready var continue_button: Button = $Continue
@onready var return_to_menu_button: Button = $ReturnToMenu

@export var world : Node2D

func _ready():
	hide_scoreboard()
	
func _process(_delta):
	if Input.is_action_just_pressed("scoreboard"):
		show_scoreboard()
	elif Input.is_action_just_released("scoreboard"):
		hide_scoreboard()
	
	if refreshTimer.is_stopped(): # handle updating of scoreboard
		update_scoreboard()
		refreshTimer.start()

func update_scoreboard():
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

# This could be smarter,
# i.e. searching, updating dynamically, sorting
func show_scoreboard(buttons=false):
	update_scoreboard()
	set_visible(true)
	if buttons:
		continue_button.visible = true
		return_to_menu_button.visible = true

func hide_scoreboard():
	set_visible(false)
	continue_button.visible = false
	return_to_menu_button.visible = false
