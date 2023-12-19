class_name BulletManager extends Node

@onready var bullet_audio = $BulletAudioPlayer
@onready var new_weapon_pickup = $new_weapon_pickup

func _ready():
	GameEvents.ability_pick_up.connect(update_audio)
	update_audio(GameManager.abilities[0], 0)

func play():
	bullet_audio.play()

func update_audio(ability, id):
	var audio_to_play = load(ability.audio)
	new_weapon_pickup.play()
	bullet_audio.stream = audio_to_play
