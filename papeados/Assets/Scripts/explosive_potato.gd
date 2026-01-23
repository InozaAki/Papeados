extends Node2D
class_name ExplosivePotato

# ============================================================================
# EXPORTS
# ============================================================================
@export_group("Explosion Settings")
@export var explosion_timer := 10.0
@export var explosion_radius := 200.0
@export var explosion_damage := 100.0

@export_group("Visual Settings")
@export var blink_speed := 0.2
@export var warning_threshold := 3.0

@export_group("Attachment Settings")
@export var attach_offset := Vector2(0, -30) 
@export var follow_player := true

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = Timer.new()
@onready var blink_timer: Timer = Timer.new()

var attached_player: Player = null
var time_remaining: float = 0.0
var is_visible_state := true


func _ready() -> void:
    _setup_timers()
    time_remaining = explosion_timer

func _process(delta: float) -> void:
    if follow_player and attached_player and is_instance_valid(attached_player):
        _follow_attached_player()
    
    _update_blink_speed()

func _setup_timers() -> void:
    timer.wait_time = explosion_timer
    timer.one_shot = true
    timer.timeout.connect(_on_explosion_timer_timeout)
    add_child(timer)
    timer.start()
    
    # Blink timer
    blink_timer.wait_time = blink_speed
    blink_timer.timeout.connect(_on_blink_timer_timeout)
    add_child(blink_timer)
    blink_timer.start()
func attach_to_player(player: Player) -> void:
    if not is_instance_valid(player):
        push_warning("ExplosivePotato: Cannot attach to invalid player.")
        return
    
    attached_player = player
    
    if follow_player:
        global_position = player.global_position + attach_offset
        print("Explosive potato attached to Player %d" % player.player_id)
    else:
        global_position = player.global_position + attach_offset
        print("Explosive potato spawned near Player %d" % player.player_id)

func _follow_attached_player() -> void:
    global_position = attached_player.global_position + attach_offset

func detach() -> void:
    attached_player = null
    follow_player = false

func _update_blink_speed() -> void:
    time_remaining = timer.time_left
    
    if time_remaining <= warning_threshold:
        var new_blink_speed = lerp(0.05, blink_speed, time_remaining / warning_threshold)
        if blink_timer.wait_time != new_blink_speed:
            blink_timer.wait_time = new_blink_speed
            blink_timer.start()

func _on_blink_timer_timeout() -> void:
    is_visible_state = !is_visible_state
    sprite.modulate.a = 1.0 if is_visible_state else 0.3

func _on_explosion_timer_timeout() -> void:
    _explode()

func _explode() -> void:
    print("BOOM! Explosive potato exploded at position: %s" % global_position)

    var players_in_range := _get_players_in_radius(explosion_radius)
    
    for player in players_in_range:
        _apply_explosion_effect(player)
    
    _create_explosion_effect()
    
    queue_free()

func _get_players_in_radius(radius: float) -> Array[Player]:
    var players_in_range: Array[Player] = []
    var all_players := _find_all_players()
    
    for player in all_players:
        if is_instance_valid(player):
            var distance := global_position.distance_to(player.global_position)
            if distance <= radius:
                players_in_range.append(player)
    
    return players_in_range

func _apply_explosion_effect(player: Player) -> void:
    """Apply explosion effects to a player"""
    var distance := global_position.distance_to(player.global_position)
    var knockback_strength := 1000.0
    
    var knockback_direction := (player.global_position - global_position).normalized()
    
    var distance_factor := 1.0 - (distance / explosion_radius)
    var knockback := knockback_direction * knockback_strength * distance_factor
    
    if player.has_method("apply_knockback"):
        player.apply_knockback(knockback)
    else:
        player.velocity += knockback
    
    print("Player %d took explosion damage! Distance: %.1f" % [player.player_id, distance])

func _create_explosion_effect() -> void:
    # TODO: Add particle effects, screen shake, sound, etc.
    pass

func _find_all_players() -> Array[Player]:
    """Find all Player instances in the scene"""
    var players: Array[Player] = []
    var root := get_tree().current_scene
    _find_players_recursive(root, players)
    return players

func _find_players_recursive(node: Node, players: Array[Player]) -> void:
    """Recursively find all Player nodes"""
    if node is Player:
        players.append(node)
    
    for child in node.get_children():
        _find_players_recursive(child, players)

func get_time_remaining() -> float:
    return timer.time_left

func add_time(seconds: float) -> void:
    var current_time = timer.time_left
    timer.stop()
    timer.wait_time = current_time + seconds
    timer.start()
    print("Added %.1f seconds to explosion timer" % seconds)

func force_explode() -> void:
    timer.stop()
    _explode()