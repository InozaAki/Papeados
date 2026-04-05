extends Node
class_name PlayerManager


# SIGNALS

signal player_spawned(player: Player)
signal player_died(player: Player)
signal player_respawned(player: Player)


# SCENES
@export var player_scene: PackedScene


# VARIABLES

var players: Dictionary[int, PlayerData]

'''
Spawns a player on the server and replicates the spawn to all clients. 
Each player is associated with a unique peer ID, and their data is stored in a dictionary for easy access. 
The function ensures that only the server can spawn players, and it uses RPC to synchronize the player spawn across all clients.

Args:
    peer_id (int): The unique identifier for the player's network connection.
    pos (Vector2): The initial position where the player will be spawned in the game world.
'''
func spawn_player(peer_id: int, pos: Vector2) -> void:

    if not Validator.ensure_server(self):
        return

    _create_player(peer_id, pos)
    _spawn_player_on_clients.rpc(peer_id, pos)

'''
Spawn a player on clients. 
This function is called via RPC from the server when a new player is spawned.

Args:
    peer_id (int): The unique identifier for the player's network connection.
    pos (Vector2): The initial position where the player will be spawned in the game world.
'''
@rpc("authority", "reliable", "call_local")
func _spawn_player_on_clients(peer_id: int, pos: Vector2) -> void:

    if multiplayer.is_server():
        return

    _create_player(peer_id, pos)

'''
Creates the player instance and sets up the necessary data structures to manage the player's state.
Also emits a signal to notify other parts of the game that a new player has been spawned.

Args:
    peer_id (int): The unique identifier for the player's network connection.
    pos (Vector2): The initial position where the player will be spawned in the game world.
'''

func _create_player(peer_id: int, pos: Vector2) -> void:
    
    if players.has(peer_id):
        return

    var player: Player = player_scene.instantiate()
    player.global_position = pos
    player.set_multiplayer_authority(peer_id)

    add_child(player)

    var data := PlayerData.new(peer_id, player)
    
    players[peer_id] = data
    player_to_id[player] = peer_id

    player_spawned.emit(player)

'''
Retrieves the player instance associated with a given peer ID.
This function allows other parts of the game to access the player instance using the unique peer ID.

Args:
    peer_id (int): The unique identifier for the player's network connection.

Returns:
    Player: The player instance associated with the given peer ID, or null if no player is found.
'''
func get_player(peer_id: int) -> Player:
    return players.get(peer_id)?.player_instance

'''
Retrieves the player data associated with a given peer ID.
This function allows other parts of the game to access the player's data, 
such as their alive status or score, using the unique peer ID.

Args:
    peer_id (int): The unique identifier for the player's network connection.

Returns:
    PlayerData: The player data associated with the given peer ID, or null if no player is found.
'''
func get_player_data(peer_id: int) -> PlayerData:
    return players.get(peer_id)

'''
Removes a player from the game when they disconnect or are removed by an explosion.

Args:
    peer_id (int): The unique identifier for the player's network connection.
'''
func remove_player(peer_id: int) -> void:
    if not players.has(peer_id):
        return
    
    var data = players[peer_id]
    
    if is_instance_valid(data.player):
        data.player.queue_free()
    
    players.erase(peer_id)

'''
Marks a player as dead in the player data dictionary and 
emits a signal to notify other parts of the game that the player has died.
This function is called when a player is killed by an explosion.

Args:
    peer_id (int): The unique identifier for the player's network connection.
'''
func mark_player_dead(peer_id: int) -> void:
    var data = players.get(peer_id)
    if data:
        data.alive = false
        player_died.emit(data.player)