class_name BulletManager extends Node

@onready var bullet_audio = $BulletAudioPlayer
@onready var new_weapon_pickup = $new_weapon_pickup

var bullet_sprites = {
	"Green": {
		"standard": "res://assets/sprites/Bullets/bullet_sprites/09.png",
		"rapid_fire": "res://assets/sprites/Bullets/bullet_sprites/16.png",
		"spread": "res://assets/sprites/Bullets/bullet_sprites/09.png",
		},
	"Red": {
		"standard": "res://assets/sprites/Bullets/bullet_sprites/02.png",
		"rapid_fire": "res://assets/sprites/Bullets/bullet_sprites/14.png",
		"spread": "res://assets/sprites/Bullets/bullet_sprites/02.png",
		},
	"Blue": {
		"standard": "res://assets/sprites/Bullets/bullet_sprites/06.png",
		"rapid_fire": "res://assets/sprites/Bullets/bullet_sprites/11.png",
		"spread": "res://assets/sprites/Bullets/bullet_sprites/06.png",
		},
	"Pink": {
		"standard": "res://assets/sprites/Bullets/bullet_sprites/03.png",
		"rapid_fire": "res://assets/sprites/Bullets/bullet_sprites/13.png",
		"spread": "res://assets/sprites/Bullets/bullet_sprites/03.png",
		}
	}

func _ready():
	GameEvents.ability_pick_up.connect(update_audio)
	update_audio(GameManager.abilities[0], 0)

func play():
	bullet_audio.play()

func update_audio(ability, id):
	var audio_to_play = load(ability.audio)
	new_weapon_pickup.play()
	bullet_audio.stream = audio_to_play
