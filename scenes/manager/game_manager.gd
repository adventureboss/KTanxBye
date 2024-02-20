extends Node
const ENVIRONMENT = 10101010
var tanks = {
	ENVIRONMENT: {
		"id": ENVIRONMENT,
		"name": "Environment",
		"color": "chartreuse",
		"score": {
			"kills": 0,
			"deaths": 0,
			"assists": 0,
		}
	}
}

var player_host = 0

var abilities = {
	0: {"name": "standard",
	   "path": "res://scenes/game_object/ammo/standard.tscn",
	   "audio": "res://assets/audio/sfx/weapon_sounds/normal_cannon_fire.mp3"
	   },
	1: {"name": "rapid_fire",
		"path": "res://scenes/game_object/ammo/rapid_fire.tscn",
		"audio": "res://assets/audio/sfx/weapon_sounds/normal_cannon_fire.mp3",
	   },
	2: {"name": "spread",
		"path": "res://scenes/game_object/ammo/spread.tscn",
		"audio": "res://assets/audio/sfx/weapon_sounds/shotgun_fire.wav",
	   },
	3: {"name": "laser",
		"path": "res://scenes/game_object/ammo/laser.tscn",
		"audio": "res://assets/audio/sfx/weapon_sounds/bfc_laser_fire.mp3",
		},
	4: {"name": "bazooka",
		"path": "res://scenes/game_object/ammo/bazooka.tscn",
		"audio": "res://assets/audio/sfx/weapon_sounds/bazooka.mp3",
		},
}

var color_dict = {
	"Blue": {"Barrel": "res://assets/sprites/Tanks/barrelBlue_outline.png",
			 "Body": "res://assets/sprites/Tanks/tankBlue_outline.png"},
	"Green": {"Barrel": "res://assets/sprites/Tanks/barrelGreen_outline.png",
			  "Body": "res://assets/sprites/Tanks/tankGreen_outline.png"},
	"Red": {"Barrel": "res://assets/sprites/Tanks/barrelRed_outline.png",
			 "Body": "res://assets/sprites/Tanks/tankRed_outline.png"},
	"Yellow": {"Barrel": "res://assets/sprites/Tanks/barrelYellow_outline.png",
			 "Body": "res://assets/sprites/Tanks/tankYellow_outline.png"},
	"Pink": {"Barrel": "res://assets/sprites/Tanks/barrelPink_outline.png",
			 "Body": "res://assets/sprites/Tanks/tankPink_outline.png"},
	"Beige": {"Barrel": "res://assets/sprites/Tanks/barrelBeige_outline.png",
			 "Body": "res://assets/sprites/Tanks/tankBeige_outline.png"},
	"Black": {"Barrel": "res://assets/sprites/Tanks/barrelBlack_outline.png",
			 "Body": "res://assets/sprites/Tanks/tankBlack_outline.png"},
}

var emotes: Array = [{
	"name": "money",
	"asset": "emote_cash.png"
},
{
	"name": "money",
	"asset": "emote_cash.png"
},
{
	"name": "sweat",
	"asset": "emote_drops.png"
},
{
	"name": "heart",
	"asset": "emote_heart.png"
},
{
	"name": "exclamation",
	"asset": "emote_exclamation.png"
},
{
	"name": "smile",
	"asset": "emote_faceHappy.png"
},
{
	"name": "music",
	"asset": "emote_music.png"
}]
