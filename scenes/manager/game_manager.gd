extends Node
const ENVIRONMENT = 10101010
var players = {
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
}

var color_dict = {
	"Blue": {"Barrel": "res://assets/sprites/Tanks/barrelBlue_outline.png",
			 "Body": "res://assets/sprites/Tanks/tankBlue_outline.png"},
	"Green": {"Barrel": "res://assets/sprites/Tanks/barrelGreen_outline.png",
			  "Body": "res://assets/sprites/Tanks/tankGreen_outline.png"},
	"Red": {"Barrel": "res://assets/sprites/Tanks/barrelRed_outline.png",
			 "Body": "res://assets/sprites/Tanks/tankRed_outline.png"},
	"Pink": {"Barrel": "res://assets/sprites/Tanks/barrelPink_outline.png",
			 "Body": "res://assets/sprites/Tanks/tankPink_outline.png"},
}
