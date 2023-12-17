extends Node

var players = {}

var abilities = {
	0: "res://scenes/ability/standard_ammo_ability/standard_ammo.tscn",
	1: "res://scenes/ability/rapid_fire_ability/rapid_fire_ammo.tscn",
	2: "spread",
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
