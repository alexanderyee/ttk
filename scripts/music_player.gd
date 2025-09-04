class_name MusicPlayer
extends AudioStreamPlayer

var tracks := [
	"res://assets/music/Musinova_Liquid_Sky.ogg",
	"res://assets/music/Musinova_Neon_Surfer.ogg",
]
const MUSINOVA_ELECTRONIC_FILENAME = "res://assets/music/Musinova_Electronic_Jungle_Indie_Loop.ogg"
var current_track_index := 0

func _ready() -> void:
	tracks.shuffle()

func play_songs() -> void:
	var track = load(tracks[current_track_index % tracks.size()])
	stream = track
	play()

func _on_music_finished() -> void:
	current_track_index += 1
	play_songs()

func play_menu_theme() -> void:
	stream = load(MUSINOVA_ELECTRONIC_FILENAME)
	play()
