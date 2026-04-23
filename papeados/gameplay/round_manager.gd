extends Node
class_name RoundManager

# Signals
signal round_started(round_number: int, rounds_to_win: int)
signal round_ended(survivor_peer_id: int)
signal round_ready_to_spawn
signal all_rounds_completed(winner_peer_id: int)

# Config variables
@export var rounds_to_win: int = 3
@export var round_end_delay: float = 3.0
@export var respawn_delay: float = 0.5

# Internal variables
var round_number: int = 0
var round_in_progress: bool = false
var players_dead_this_round: Array[int] = []


'''
Maneja la lógica de inicio de ronda, 
incluyendo la regeneración del mapa, el respawn de jugadores muertos, 
y la emisión de señales para actualizar la UI y permitir el spawn de papas.

Args:
	player_manager (PlayerManager): El PlayerManager para gestionar el estado de los jugadores al inicio de la ronda.

Emits:
	round_started(round_number: int, rounds_to_win: int): 
		(RPC) Emitida a todos los clientes para anunciar el inicio de una nueva 
		ronda con su número y la cantidad de rondas necesarias para ganar.
	round_ready_to_spawn: Emitida por el servidor después de iniciar la ronda para indicar que es seguro spawnear papas.

'''
func start_round(player_manager: PlayerManager) -> void:
	if not Validator.ensure_server(self):
		return
 
	if round_in_progress:
		push_warning("[RoundManager] Intento de iniciar ronda mientras una ya está en progreso.")
		return
 
	var arena = _get_arena()
	if arena:
		arena.regenerate_for_round()
 
	for peer_id in players_dead_this_round.duplicate():
		player_manager.respawn_player(peer_id)
	players_dead_this_round.clear()
 
	await get_tree().create_timer(respawn_delay).timeout
 
	round_number += 1
	round_in_progress = true
 
	for peer_id in player_manager.get_all_peer_ids():
		player_manager.mark_player_alive(peer_id)
 
	print("[RoundManager] === Comenzando Ronda %d ===" % round_number)
	_announce_round_start.rpc(round_number, rounds_to_win)
	round_ready_to_spawn.emit()

@rpc("authority", "reliable", "call_local")
func _announce_round_start(number: int, to_win: int) -> void:
	round_started.emit(number, to_win)

'''
Verifica si la ronda ha terminado evaluando el estado de los jugadores vivos.
Si la ronda terminó, maneja la lógica de fin de ronda, incluyendo el anuncio del sobreviviente,
la actualización de puntajes, y la preparación para la siguiente ronda o el fin del juego.

Args:
	player_manager (PlayerManager): El PlayerManager para consultar el estado de los jugadores vivos.
	score_manager (ScoreManager): El ScoreManager para actualizar puntajes y verificar condiciones de victoria.
	potato_manager (PotatoManager): El PotatoManager para detener el spawn de papas si la ronda termina.

'''
func check_round_end(player_manager: PlayerManager, score_manager: ScoreManager, potato_manager: PotatoManager) -> void:
	if not Validator.ensure_server(self):
		return
 
	var alive = player_manager.get_alive_peer_ids()
	print("[RoundManager] Jugadores vivos: %d" % alive.size())
 
	if alive.size() <= 1:
		var survivor_id = alive[0] if alive.size() == 1 else -1
		await _finish_round(survivor_id, player_manager, score_manager, potato_manager)
	else:
		await get_tree().create_timer(1.0).timeout
		var target = player_manager.get_random_alive_player()
		if target:
			potato_manager.spawn_potato_on_player(target, player_manager)
			potato_manager.start_spawn_timer()

'''
Maneja la lógica de fin de ronda, incluyendo el anuncio del sobreviviente, 
la actualización de puntajes, y la preparación para la siguiente ronda o el fin del juego.

Esta función es llamada por el servidor cuando se detecta que la ronda ha terminado 
para procesar el resultado y avanzar al siguiente estado del juego.

Args:
	survivor_peer_id (int): El network peer ID del sobreviviente de la ronda, o -1 si no hay sobrevivientes.
	player_manager (PlayerManager): El PlayerManager para gestionar el estado de los jugadores al finalizar la ronda.
	score_manager (ScoreManager): El ScoreManager para actualizar puntajes y verificar condiciones de victoria.
	potato_manager (PotatoManager): El PotatoManager para detener el spawn de papas si la ronda termina.

'''
func _finish_round(survivor_peer_id: int, player_manager: PlayerManager, score_manager: ScoreManager, potato_manager: PotatoManager) -> void:
	round_in_progress = false
	potato_manager.stop_spawn_timer()
 
	print("[RoundManager] === FIN DE RONDA %d ===" % round_number)
	_announce_round_end.rpc(survivor_peer_id)
 
	await get_tree().create_timer(round_end_delay).timeout
 
	if survivor_peer_id != -1 and score_manager.has_won(survivor_peer_id, rounds_to_win):
		_trigger_game_over_scenes.rpc(survivor_peer_id)
		return
 
	start_round(player_manager)


'''
Usada para anunciar el fin de la ronda a todos los clientes, indicando quién sobrevivió (si alguien sobrevivió).

Args:
	survivor_peer_id (int): El network peer ID del sobreviviente de la ronda, o -1 si no hay sobrevivientes.
'''
@rpc("authority", "reliable", "call_local")
func _announce_round_end(survivor_peer_id: int) -> void:
	print("[RoundManager] Ronda terminada. Superviviente: %d" % survivor_peer_id)
	round_ended.emit(survivor_peer_id)

'''
Marca a un jugador como muerto y lo registra en la lista de jugadores muertos de esta ronda.
Esta función es llamada por el PlayerManager cuando un jugador muere para actualizar su estado y permitir
que el RoundManager lleve un seguimiento de quién ha muerto durante la ronda actual.

Args:
	peer_id (int): El network peer ID del jugador a marcar como muerto.
	player_manager (PlayerManager): La instancia del PlayerManager para actualizar el estado del jugador.
'''
func register_death(peer_id: int, player_manager: PlayerManager) -> void:
	player_manager.mark_player_dead(peer_id)
	if peer_id not in players_dead_this_round:
		players_dead_this_round.append(peer_id)

func _get_arena():
	return get_parent().get_node_or_null("Platforms")
	
@rpc("authority", "reliable", "call_local")
func _trigger_game_over_scenes(winner_id: int) -> void:
	var mi_id = multiplayer.get_unique_id()
	
	if mi_id == winner_id:
		get_tree().change_scene_to_file("res://scenes/pantalla_ganador.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/pantalla_perdedor.tscn")
