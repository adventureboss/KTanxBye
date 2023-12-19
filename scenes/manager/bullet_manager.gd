class_name BulletManager extends Node

@onready var bullet_audio = $BulletAudioPlayer

func _ready():
	GameEvents.ability_pick_up.connect(update_audio)
	update_audio(GameManager.abilities[0], 0)

func play():
	bullet_audio.play()

func update_audio(ability, id):
	var audio_to_play = load(ability.audio)
	bullet_audio.stream = audio_to_play
