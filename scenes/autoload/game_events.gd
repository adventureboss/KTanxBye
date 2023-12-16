extends Node

signal ability_pick_up(ability, id)

func emit_ability_pick_up(ability, id):
	ability_pick_up.emit(ability, id)
