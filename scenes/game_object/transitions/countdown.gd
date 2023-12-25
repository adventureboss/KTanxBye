extends Node2D
class_name Countdown

@onready var countdown_camera: Camera2D = $Camera
@onready var countdown_timer: Timer = $Timer
signal countdown_completed

func start_countdown(player_camera: Camera2D):
	# make visible whatever UI
	CameraTransitions.transition_camera(countdown_camera, player_camera, 3.0)
	countdown_timer.start()

func time_left() -> float:
	return countdown_timer.time_left

# it'd also be cool to display the timer in the center, 
# then go for the more subtle timer
func _on_timer_timeout():
	countdown_completed.emit()
