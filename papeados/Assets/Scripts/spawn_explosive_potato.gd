extends Node
class_name ExplosivePotatoSpawner

@export var explosive_potato_scene: PackedScene
@export var spawn_interval := 15.0  
@export var auto_spawn := true  
@export var spawn_on_ready := true

var spawn_timer: Timer

func _ready() -> void:
    if auto_spawn:
        _setup_spawn_timer()
    
    if spawn_on_ready:
        spawn_on_random_player()

func _setup_spawn_timer() -> void:
    spawn_timer = Timer.new()
    spawn_timer.wait_time = spawn_interval
    spawn_timer.one_shot = false
    spawn_timer.timeout.connect(_on_spawn_timer_timeout)
    add_child(spawn_timer)
    spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
    spawn_on_random_player()

func spawn_on_random_player() -> ExplosivePotato:
    var players := _get_all_players()
    
    if players.is_empty():
        push_warning("ExplosivePotatoSpawner: No players found.")
        return null
    
    var selected_player = players.pick_random()
    return spawn_on_player(selected_player)

func spawn_on_player(player: Player) -> ExplosivePotato:
    if not explosive_potato_scene:
        push_error("ExplosivePotatoSpawner: explosive_potato_scene is not assigned!")
        return null
    
    if not is_instance_valid(player):
        push_warning("ExplosivePotatoSpawner: Invalid player reference.")
        return null
    
    var potato: ExplosivePotato = explosive_potato_scene.instantiate()
    
    var spawn_parent := _get_spawn_parent()
    spawn_parent.add_child.call_deferred(potato)
    
    potato.attach_to_player(player)
    
    return potato

func spawn_on_player_by_id(player_id: int) -> ExplosivePotato:
    var player := _find_player_by_id(player_id)
    
    if player:
        return spawn_on_player(player)
    else:
        push_warning("ExplosivePotatoSpawner: Player with ID %d not found." % player_id)
        return null

func _get_all_players() -> Array[Player]:
    var players: Array[Player] = []
    var root := get_tree().current_scene
    _find_players_recursive(root, players)
    return players

func _find_players_recursive(node: Node, players: Array[Player]) -> void:
    if node is Player:
        players.append(node)
    
    for child in node.get_children():
        _find_players_recursive(child, players)

func _find_player_by_id(player_id: int) -> Player:
    var players := _get_all_players()
    
    for player in players:
        if player.player_id == player_id:
            return player
    
    return null

func _get_spawn_parent() -> Node:
    var parent := get_parent()
    return parent if parent else get_tree().current_scene

func start_auto_spawn() -> void:
    if not spawn_timer:
        _setup_spawn_timer()
    else:
        spawn_timer.start()

func stop_auto_spawn() -> void:
    if spawn_timer:
        spawn_timer.stop()

func set_spawn_interval(seconds: float) -> void:
    spawn_interval = seconds
    if spawn_timer:
        spawn_timer.wait_time = seconds
