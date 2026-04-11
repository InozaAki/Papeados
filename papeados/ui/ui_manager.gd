extends Node
class_name UIManager

@export var round_label: Label
@export var players_label: Label

var _player_manager: PlayerManager
var _score_manager: ScoreManager

func _ready() -> void:
	print("[UIManager] Ready")

	var game_manager = get_tree().current_scene
	if not game_manager:
		push_error("[UIManager] No se encontró GameManager.")
		return

	_player_manager = game_manager.get_node_or_null("PlayerManager")
	_score_manager = game_manager.get_node_or_null("ScoreManager")
	var round_manager: RoundManager = game_manager.get_node_or_null("RoundManager")

	if round_manager:
		round_manager.round_started.connect(_on_round_started)
		round_manager.round_ended.connect(_on_round_ended)

	if _player_manager:
		_player_manager.player_spawned.connect(_on_roster_changed)
		_player_manager.player_removed.connect(_on_roster_changed)

	if _score_manager:
		_score_manager.score_updated.connect(_on_score_updated)

func _on_round_started(round_number: int, rounds_to_win: int) -> void:
	if round_label:
		round_label.text = "Ronda %d — Primero en %d gana" % [round_number, rounds_to_win]
	_rebuild_players_label()

func _on_round_ended(survivor_peer_id: int) -> void:
	if round_label:
		if survivor_peer_id == -1:
			round_label.text = "¡Empate!"
		else:
			round_label.text = "¡Jugador %d sobrevivió!" % survivor_peer_id

func _on_roster_changed(_ignored) -> void:
	_rebuild_players_label()

func _on_score_updated(_peer_id: int, _score: int) -> void:
	_rebuild_players_label()

func _rebuild_players_label() -> void:
	if not players_label or not _player_manager:
		return

	var alive_ids = _player_manager.get_alive_peer_ids()
	var text = ""

	for peer_id in _player_manager.get_all_peer_ids():
		var score = _score_manager.get_score(peer_id) if _score_manager else 0
		var alive = peer_id in alive_ids
		var status = "" if alive else " 💀"
		text += "Jugador %d — %d pts%s\n" % [peer_id, score, status]

	players_label.text = text.strip_edges()
