extends Node
class_name PlayerManager

# Internal class
class PlayerData:
	var peer_id: int
	var player_instance: Player
	var alive: bool = true
 
	func _init(id: int, instance: Player) -> void:
		peer_id = id
		player_instance = instance

# Signals
signal player_spawned(player: Player)
signal player_removed(peer_id: int)

# Scenes
@export var player_scene: PackedScene
@export var spawn_positions: Array[Vector2] = [
	Vector2(-200, 0),
	Vector2(200, 0),
	Vector2(-200, -100),
	Vector2(200, -100)
]

# Internal variables
var players: Dictionary = {}         # peer_id -> PlayerData
var _player_to_id: Dictionary = {}   # Player -> peer_id
var _next_spawn_index := 0


'''
Spawnea un nuevo jugador con el peer_id dado. 

Solo el servidor debe llamar a esta función.

Después de crear la instancia del jugador, se llama a un RPC para que todos los clientes
 creen la misma instancia en su escena.

Args:
	peer_id (int): El network peer ID del jugador a spawnear.
'''
func spawn_player(peer_id: int) -> void:
	if not Validator.ensure_server(self):
		return

	if players.has(peer_id):
		push_warning("[PlayerManager] El jugador %d ya existe." % peer_id)
		return

	var pos = _get_next_spawn_pos()
	_create_player(peer_id, pos)
	_spawn_player_on_clients.rpc(peer_id, pos)


'''
Solicita a los clientes que creen la instancia del jugador con el peer_id y posición dada.

Solo se llama desde el servidor después de crear la instancia del jugador para sincronizarla en los clientes.

Args:
	peer_id (int): El network peer ID del jugador a spawnear.
	pos (Vector2): La posición donde el jugador debe ser spawneado.
'''
@rpc("authority", "reliable")
func _spawn_player_on_clients(peer_id: int, pos: Vector2) -> void:
	if multiplayer.is_server():
		return
	_create_player(peer_id, pos)


'''
Crea la instancia del jugador, la configura y la registra en las estructuras de datos internas.
Solo se llama desde el servidor para crear la instancia y luego se sincroniza en los clientes a través de un RPC.

Args:
	peer_id (int): El network peer ID del jugador.
	pos (Vector2): La posición donde el jugador debe ser spawneado.

Emits:
	player_spawned(player: Player): Emitido después de que la instancia del jugador sea creada y agregada a la escena.
'''
func _create_player(peer_id: int, pos: Vector2) -> void:
	if players.has(peer_id):
		return
 
	var player: Player = player_scene.instantiate()
 
	player.player_id = peer_id
	player.name = "Player_%d" % peer_id
	player.set_multiplayer_authority(peer_id)
 
	add_child(player)
 
	player.global_position = pos
 
	var data := PlayerData.new(peer_id, player)
	players[peer_id] = data
	_player_to_id[player] = peer_id
 
	print("[PlayerManager] Jugador %d creado en %v" % [peer_id, pos])
	player_spawned.emit(player)

'''
Respawnea a un jugador por su peer_id.

Solo el servidor debe llamar a esta función.

Utiliza la misma lógica que spawn_player para limpiar la instancia vieja (si existe) y 
crear una nueva en una posición de spawn.

Args:
	peer_id (int): El network peer ID del jugador a respawnear.
'''
func respawn_player(peer_id: int) -> void:
	if not Validator.ensure_server(self):
		return

	# Limpiar instancia vieja si aún existe
	if players.has(peer_id):
		var old_data: PlayerData = players[peer_id]
		if is_instance_valid(old_data.player_instance):
			_player_to_id.erase(old_data.player_instance)
			old_data.player_instance.queue_free()
		players.erase(peer_id)

	var pos = _get_next_spawn_pos()
	_create_player(peer_id, pos)
	_spawn_player_on_clients.rpc(peer_id, pos)

	print("[PlayerManager] Jugador %d respawneado en %v" % [peer_id, pos])


'''
Elimina el jugador con el peer_id dado.
Solo se ejecuta en el servidor. Después de eliminar la instancia del jugador, llama a un RPC para eliminarla en todos los clientes.

Args:
	peer_id (int): El network peer ID del jugador a eliminar.
'''
func remove_player(peer_id: int) -> void:
	if not players.has(peer_id):
		return

	_remove_player_on_clients.rpc(peer_id)


'''
Utilizado por el servidor para eliminar la instancia del jugador con el peer_id dado y 
limpiar las estructuras de datos internas.

Args:
	peer_id (int): El network peer ID del jugador a eliminar.
'''
@rpc("any_peer", "reliable", "call_local")
func _remove_player_on_clients(peer_id: int) -> void:
	if not players.has(peer_id):
		return

	var data: PlayerData = players[peer_id]
	if is_instance_valid(data.player_instance):
		_player_to_id.erase(data.player_instance)
		data.player_instance.queue_free()

	players.erase(peer_id)
	player_removed.emit(peer_id)
	print("[PlayerManager] Jugador %d removido." % peer_id)


'''
Marca a un jugador como muerto. 
Esto es utilizado por el RoundManager para llevar un seguimiento de quién sigue vivo en la ronda actual.

Args:
	peer_id (int): El network peer ID del jugador a marcar como muerto.
'''
func mark_player_dead(peer_id: int) -> void:
	var data: PlayerData = players.get(peer_id)
	if data:
		data.alive = false

'''
Marca a un jugador como vivo. Esto es utilizado por el RoundManager para respawnear jugadores al principio de una nueva ronda.

Args:
	peer_id (int): El network peer ID del jugador a marcar como vivo.
'''
func mark_player_alive(peer_id: int) -> void:
	var data: PlayerData = players.get(peer_id)
	if data:
		data.alive = true

func get_alive_peer_ids() -> Array[int]:
	var result: Array[int] = []
	for peer_id in players:
		if players[peer_id].alive:
			result.append(peer_id)
	return result

func get_player(peer_id: int) -> Player:
	var data: PlayerData = players.get(peer_id)
	return data.player_instance if data else null

func get_peer_id_of(player: Player) -> int:
	return _player_to_id.get(player, -1)

func get_random_alive_player() -> Player:
	var alive = get_alive_peer_ids()
	if alive.is_empty():
		return null
	return get_player(alive.pick_random())

func get_player_position(peer_id: int) -> Vector2:
	var player = get_player(peer_id)
	return player.global_position if player else Vector2.ZERO

func has_player(peer_id: int) -> bool:
	return players.has(peer_id)

func get_all_peer_ids() -> Array:
	return players.keys()

func count() -> int:
	return players.size()

func _get_next_spawn_pos() -> Vector2:
	var pos = spawn_positions[_next_spawn_index % spawn_positions.size()]
	_next_spawn_index += 1
	return pos
