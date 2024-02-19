extends Node2D
class_name ArenaTimeManager

signal one_minute_left

@onready var round_timer = $RoundTimer
var scoreboard = null


func _ready() -> void:
	scoreboard = get_tree().get_first_node_in_group("Scoreboard")
	round_timer.timeout.connect(on_round_timer_timeout)


func _process(_delta) -> void:
		if round_timer.time_left < 60 && round_timer.time_left > 59:
			one_minute_left.emit()

func start(map_time : int) -> void:
	round_timer.wait_time = map_time
	round_timer.start()


func time_left() -> float:
	return round_timer.time_left


func pause_round() -> void:
	for player in get_tree().get_nodes_in_group("player"):
		player.process_mode = Node.PROCESS_MODE_DISABLED


func format_time(seconds: float) -> String:
	var minutes = floor(seconds / 60)
	var remaining_seconds = seconds - (minutes * 60)
	return str(minutes) + ":" + ("%02d" % floor(remaining_seconds))


func on_round_timer_timeout() -> void:
	pause_round()
	scoreboard.show_scoreboard(true)
	
	# ideas:
	# - camera zoom out
	# - trigger UI round over with scoreboard

