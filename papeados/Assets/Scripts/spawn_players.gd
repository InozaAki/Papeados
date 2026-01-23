extends Node2D

@export var player_scene: PackedScene
@export var spawn_positions: Array[Vector2] = [Vector2(-200, 0), Vector2(200, 0)]

func _ready() -> void:
    spawn_players()

func spawn_players() -> void:
    for i in spawn_positions.size():
        var player_instance = player_scene.instantiate()
        player_instance.position = spawn_positions[i]
        player_instance.player_id = i + 1
        add_child(player_instance)