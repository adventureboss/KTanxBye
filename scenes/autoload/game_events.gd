extends Node

signal ability_pick_up(ability, id, position)

func emit_ability_pick_up(ability, id, position):
	ability_pick_up.emit(ability, id, position)

