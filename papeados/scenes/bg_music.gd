extends Node

@onready var background_music = $AudioStreamPlayer

var MAIN_MUSIC: AudioStream = preload("res://assets/sounds/music/cheered_on.ogg")

func _ready():
	play_main_music()

func play_music(stream: AudioStream):
	if background_music.stream == stream:
		return
	
	background_music.stream = stream
	background_music.play()

func play_main_music():
	play_music(MAIN_MUSIC)

func pause_music():
	background_music.stream_paused = true

func resume_music():
	background_music.stream_paused = false
