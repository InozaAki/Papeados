extends Node

@onready var background_music = $AudioStreamPlayer

var MAIN_MUSIC: AudioStream = preload("res://assets/sounds/music/cheered_on.ogg")
var GAME_MUSIC: AudioStream = preload("res://assets/sounds/music/fight.ogg")

func play_music(stream: AudioStream):
	if background_music.stream == stream:
		return
	
	background_music.stream = stream
	background_music.play()

func play_main_music():
	play_music(MAIN_MUSIC)

func play_game_music():
	play_music(GAME_MUSIC)

func pause_music():
	background_music.stream_paused = true

func resume_music():
	background_music.stream_paused = false
