extends Node

class PlayerData:
	var player_id: int
	var player_instance: Player
	var alive: bool = true
	var score: int = 0
	var can_receive_potato: bool = true
	var can_transfer_potato: bool = true
	var has_potato: bool = false

	func _init(id: int, instance: Player) -> void:
		player_id = id
		player_instance = instance
