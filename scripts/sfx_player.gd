class_name SFXPlayer
extends AudioStreamPlayer

@export var typo_sfx_cooldown_s = 0.0

enum SFX {WORD_TYPED, PERFECT_WORD_1, PERFECT_WORD_2, PERFECT_WORD_3, PERFECT_WORD_4, PERFECT_WORD_5, TYPO}
const SOUNDS := {
	SFX.WORD_TYPED: preload("res://assets/sfx/Minimalist13.ogg"),
	SFX.PERFECT_WORD_1: preload("res://assets/sfx/kill1.ogg"),
	SFX.PERFECT_WORD_2: preload("res://assets/sfx/kill2.ogg"),
	SFX.PERFECT_WORD_3: preload("res://assets/sfx/kill3.ogg"),
	SFX.PERFECT_WORD_4: preload("res://assets/sfx/kill4.ogg"),
	SFX.PERFECT_WORD_5: preload("res://assets/sfx/kill5.ogg"),
	SFX.TYPO: preload("res://assets/sfx/honk.wav")
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func play_sfx(sfx: SFX):
	if SOUNDS.has(sfx):
		if sfx == SFX.TYPO:
			volume_db = -5.0
			pitch_scale = 1.0 + randf_range(-0.1, 0.1)
		else: 
			volume_db = 0.0
			pitch_scale = 1.0
		stream = SOUNDS[sfx]
		play()
	else:
		push_warning("No sfx found for: " + str(sfx))
