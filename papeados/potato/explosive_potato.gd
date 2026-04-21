extends Node2D
class_name ExplosivePotato

signal exploding(players_in_range: Array[Player])

var has_exploded := false

@export_group("Explosion Settings")
@export var explosion_timer := 10.0
@export var explosion_radius := 200.0
@export var knockback_strength := 1000.0

@export_group("Visual Settings")
@export var blink_speed := 0.2
@export var warning_threshold := 3.0

@export_group("Attachment Settings")
@export var attach_offset := Vector2(0, -30)
@export var attach_delay := 1.0
@export var sprite: Sprite2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = Timer.new()
@onready var blink_timer: Timer = Timer.new()

@export_group("Sounds")
@export var explosion_sound: AudioStreamWAV
@export var attach_sound: AudioStreamMP3
@export var warning_sound: AudioStreamOggVorbis

@onready var audio = $AudioStreamPlayer2D

var attached_player: Player = null
var is_visible_state := true

func _ready() -> void:
	if not sprite:
		sprite = _find_sprite_node()
	if animated_sprite:
		animated_sprite.visible = false
		animated_sprite.stop()
	_setup_timers()

func _find_sprite_node() -> Sprite2D:
	for child in get_children():
		if child is Sprite2D:
			return child
	return null

func _process(_delta: float) -> void:
	if attached_player and is_instance_valid(attached_player):
		global_position = attached_player.global_position + attach_offset
	_update_blink_speed()
	countdown_sound()

func countdown_sound() -> void:
	if has_exploded:
		return

	var time_remaining = get_time_remaining()
	if time_remaining <= warning_threshold:
		if not audio.playing or audio.stream != warning_sound:
			_play_warning_sound()

func _setup_timers() -> void:
	timer.wait_time = explosion_timer
	timer.one_shot = true
	timer.timeout.connect(_explode)
	add_child(timer)
	timer.start()

	blink_timer.wait_time = blink_speed
	blink_timer.timeout.connect(_toggle_visibility)
	add_child(blink_timer)
	blink_timer.start()
	has_exploded = false
	is_visible_state = true
	if sprite:
		sprite.visible = true

func attach_to_player(player: Player) -> void:
	if not is_instance_valid(player):
		return

	attached_player = player
	global_position = player.global_position + attach_offset

	_play_attach_sound()

	player.set_can_transfer_potato(false)
	await get_tree().create_timer(attach_delay).timeout
	if is_instance_valid(player):
		player.set_can_transfer_potato(true)

func _update_blink_speed() -> void:
	var time_remaining = timer.time_left
	if time_remaining <= warning_threshold:
		var new_speed = lerp(0.05, blink_speed, time_remaining / warning_threshold)
		if abs(blink_timer.wait_time - new_speed) > 0.01:
			blink_timer.wait_time = new_speed

func _toggle_visibility() -> void:
	is_visible_state = !is_visible_state
	if sprite:
		sprite.visible = is_visible_state

func _explode() -> void:
	has_exploded = true
	if sprite:
		sprite.visible = false
	if animated_sprite:
		animated_sprite.visible = true
		animated_sprite.play("explosion")
	_play_explosion_sound()

	var players_in_range := _get_players_in_radius()
	for player in players_in_range:
		_apply_knockback(player)

	exploding.emit(players_in_range)

	await audio.finished
	queue_free()

func _get_players_in_radius() -> Array[Player]:
	var result: Array[Player] = []
	for player in get_tree().get_nodes_in_group("players"):
		if is_instance_valid(player):
			var distance := global_position.distance_to(player.global_position)
			if distance <= explosion_radius:
				result.append(player)
	return result

func _apply_knockback(player: Player) -> void:
	var distance := global_position.distance_to(player.global_position)
	var direction := (player.global_position - global_position).normalized()
	var factor := 1.0 - (distance / explosion_radius)
	var knockback := direction * knockback_strength * factor
	player.apply_knockback(knockback)

func get_time_remaining() -> float:
	return timer.time_left

func force_explode() -> void:
	timer.stop()
	_explode()

# AUDIO #
func _play_explosion_sound() -> void:
	audio.stream = explosion_sound
	audio.play()

func _play_warning_sound() -> void:
	audio.stream = warning_sound
	audio.play()

func _play_attach_sound() -> void:
	audio.stream = attach_sound
	audio.play()
