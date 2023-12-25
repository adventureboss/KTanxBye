extends Control

@onready var join_button: Button = $Join
@onready var host_button: Button = $Host
@onready var quit_button: Button = $Quit

signal join_pressed()
signal host_pressed()
signal quit_pressed()

func _ready():
	# get multiplayer manager and subscribe it
	join_pressed.connect(get_node("/root/Main").on_join_pressed)
	host_pressed.connect(get_node("/root/Main").on_host_pressed)
	quit_pressed.connect(get_node("/root/Main").on_quit_pressed)

func _on_join_pressed():
	join_pressed.emit()

func _on_host_pressed():
	host_pressed.emit()

func _on_quit_pressed():
	quit_pressed.emit()
