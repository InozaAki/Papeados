extends Node
class_name ScoreManager

# Signals
signal score_updated(peer_id: int, new_score: int)

# Internal variables
var scores: Dictionary = {}  # peer_id -> int


# Initialization
func initialize(peer_ids: Array) -> void:
	scores.clear()
	for peer_id in peer_ids:
		scores[peer_id] = 0
	print("[ScoreManager] Marcador inicializado para %d jugadores." % peer_ids.size())

'''
Usado para registrar un nuevo jugador en el marcador. 
Solo se debe llamar desde el GameManager cuando un nuevo jugador se une al juego 
para asegurarse de que estén rastreados en los puntajes.

Args:
    peer_id (int): El network peer ID del jugador a registrar en el marcador.
'''
func register_player(peer_id: int) -> void:
	if not scores.has(peer_id):
		scores[peer_id] = 0


'''
Agrega un punto al puntaje del jugador. 
Solo se ejecuta en el servidor. 
Después de actualizar el puntaje, llama a un RPC para sincronizarlo en todos los clientes.

Args:
	peer_id (int): El network peer ID del jugador al que agregar un punto.
'''
func add_score(peer_id: int) -> void:
	if not Validator.ensure_server(self):
		return

	if not scores.has(peer_id):
		push_warning("[ScoreManager] Jugador %d no registrado en el marcador." % peer_id)
		return

	scores[peer_id] += 1
	_sync_score.rpc(peer_id, scores[peer_id])
	print("[ScoreManager] Jugador %d → %d puntos" % [peer_id, scores[peer_id]])


'''
Utilizado para sincronizar el puntaje actualizado de un jugador a todos 
los clientes después de que el servidor lo haya modificado.
Solo se llama desde el servidor después de actualizar el 
puntaje de un jugador para asegurar que todos los clientes tengan el puntaje correcto.

Args:
	peer_id (int): El network peer ID del jugador cuyo puntaje se actualizó.
	new_score (int): El nuevo valor de puntaje para el jugador.
'''
@rpc("authority", "reliable", "call_local")
func _sync_score(peer_id: int, new_score: int) -> void:
	scores[peer_id] = new_score
	score_updated.emit(peer_id, new_score)

func has_won(peer_id: int, rounds_to_win: int) -> bool:
	return scores.get(peer_id, 0) >= rounds_to_win

func get_score(peer_id: int) -> int:
	return scores.get(peer_id, 0)

func get_all_scores() -> Dictionary:
	return scores.duplicate()

func remove_player(peer_id: int) -> void:
	scores.erase(peer_id)
