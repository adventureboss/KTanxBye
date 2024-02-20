extends CanvasLayer

@onready var player: AnimationPlayer = $TransitionPlayer
func transition(callback: Callable):
	#player.play('DISSOLVE')
	#await player.animation_finished
	callback.call()
	#player.play_backwards('DISSOLVE')
