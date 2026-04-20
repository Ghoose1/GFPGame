extends Node

const MENU_MUSIC_PATH : String = "res://Audio/Menu_music.mp3"
const LEVEL_MUSIC_PATH : String = "res://Audio/Background_music.mp3"

const SFX_WRONG_PLACE : AudioStream = preload("res://Audio/Wrong_domino.wav")
const SFX_BUY : AudioStream = preload("res://Audio/Buy_Sound.wav")
const SFX_PLACE : AudioStream = preload("res://Audio/Domino_Placed.ogg")
const SFX_SCORE : AudioStream = preload("res://Audio/Loop_Scored.wav")

var music_player : AudioStreamPlayer
var current_music_path : String = ""

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	add_child(music_player)

	music_player.volume_db = -20.0
	music_player.bus = "Master"
	music_player.finished.connect(_on_music_finished)

func _on_music_finished() -> void:
	if music_player.stream != null:
		music_player.play()

func play_menu_music() -> void:
	_play_music_from_path(MENU_MUSIC_PATH, LEVEL_MUSIC_PATH)

func play_level_music() -> void:
	_play_music_from_path(LEVEL_MUSIC_PATH)

func stop_music() -> void:
	if music_player.playing:
		music_player.stop()

func play_wrong_place() -> void:
	_play_sfx(SFX_WRONG_PLACE, -15.0)

func play_buy() -> void:
	_play_sfx(SFX_BUY, -15.0)

func play_place() -> void:
	_play_sfx(SFX_PLACE, -15.0)

func play_score() -> void:
	_play_sfx(SFX_SCORE, -15.0)

func _play_music_from_path(path : String, fallback_path : String = "") -> void:
	var chosen_path : String = path

	if not ResourceLoader.exists(chosen_path) and fallback_path != "":
		chosen_path = fallback_path

	if not ResourceLoader.exists(chosen_path):
		push_warning("Music file not found: " + path)
		return

	if current_music_path == chosen_path and music_player.playing:
		return

	var stream : AudioStream = load(chosen_path) as AudioStream
	if stream == null:
		push_warning("Failed to load music: " + chosen_path)
		return

	current_music_path = chosen_path
	music_player.stop()
	music_player.stream = stream
	music_player.play()

func _play_sfx(stream : AudioStream, volume_db : float = 0.0) -> void:
	if stream == null:
		return

	var player : AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(player)

	player.stream = stream
	player.volume_db = volume_db
	player.bus = "Master"
	player.finished.connect(player.queue_free)
	player.play()
