extends Node

@export var base_gravity := 900
var gravity_multiplier := 1.0

func get_gravity() -> float:
	return base_gravity * gravity_multiplier

'''
Invierte temporalmente la gravedad global y fuerza a los jugadores a
recalcular contacto con el suelo para aplicar el cambio de inmediato.

Args:
	duration (float): Tiempo en segundos que dura la inversión.
'''
func invert_gravity(duration: float) -> void:
	gravity_multiplier = -1.0

	for player in get_tree().get_nodes_in_group("players"):
		if player is Player:
			player.force_leave_floor()
	
	await get_tree().create_timer(duration).timeout
	
	gravity_multiplier = 1.0

	for player in get_tree().get_nodes_in_group("players"):
		if player is Player:
			player.force_leave_floor()
