extends Node
class_name PotatoManager

var active_potatoes: Array[ExplosivePotato]

var exists_potato := false

func spawn_random(players: Dictionary) -> void:
	
	if exists_potato: 
		return

	if players.is_empty():
		return

	var player_keys = players.keys()
	var random_key = player_keys.pick_random()

	



func _create_timer(wait: float, callback: Callable) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait
	timer.one_shot = true
	timer.timeout.connect(callback)
	add_child(timer)
	timer.start()
	return timer
