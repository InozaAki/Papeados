extends Node

@export var animated_sprite: AnimatedSprite2D
@export var player: Player
@export var trail_length: int = 8
@export var fade_duration: float = 0.3
@export var emit_every_n_frames: int = 4
@export var initial_alpha: float = 0.6

var _pool: Array[AnimatedSprite2D] = []

var _active: Array = []

var _ready_to_use: bool = false

func _ready() -> void:
	if not animated_sprite:
		return
	if not player:
		return

	await get_tree().process_frame
	_setup_pool()


'''
Preinstancia un pool de sprites fantasma para reutilizarlos durante el dash
y evitar allocaciones en tiempo real.
'''
func _setup_pool() -> void:
	var parent := player.get_parent()
	var sf := animated_sprite.sprite_frames

	for i in range(trail_length):
		var s := AnimatedSprite2D.new()
		s.sprite_frames = sf
		s.top_level = true
		s.z_index = animated_sprite.z_index - 1
		s.modulate.a = 0.0
		s.visible = false
		parent.add_child(s)
		_pool.append(s)

	_ready_to_use = true

func _process(delta: float) -> void:
	if not _ready_to_use:
		return

	var fade_step := delta / fade_duration
	var i := _active.size() - 1
	while i >= 0:
		var entry: Dictionary = _active[i]
		entry.alpha -= fade_step
		if entry.alpha <= 0.0:
			var s: AnimatedSprite2D = entry.sprite
			s.visible = false
			s.modulate.a = 0.0
			_pool.append(s)
			_active.remove_at(i)
		else:
			entry.sprite.modulate.a = entry.alpha
		i -= 1

	if not is_instance_valid(player) or not player.is_dashing:
		return
	if _pool.is_empty():
		return
	if (get_tree().get_frame() % emit_every_n_frames) != 0:
		return

	_emit_ghost()

'''
Toma un sprite del pool, copia el frame actual del jugador y lo agrega
a la lista activa para desvanecimiento progresivo.
'''
func _emit_ghost() -> void:
	var s: AnimatedSprite2D = _pool.pop_back()
	s.sprite_frames = animated_sprite.sprite_frames
	s.scale = animated_sprite.scale
	s.animation = animated_sprite.animation
	s.frame = animated_sprite.frame
	s.flip_h = animated_sprite.flip_h
	s.global_transform = animated_sprite.global_transform
	s.modulate.a = initial_alpha
	s.visible = true

	_active.append({ "sprite": s, "alpha": initial_alpha })

func _exit_tree() -> void:
	for s in _pool:
		if is_instance_valid(s):
			s.queue_free()
	for entry in _active:
		if is_instance_valid(entry.sprite):
			entry.sprite.queue_free()
	_pool.clear()
	_active.clear()
