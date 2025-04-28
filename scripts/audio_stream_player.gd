class_name SFXPlayer
extends AudioStreamPlayer

enum SFX {TYPO, WORD_TYPED}
const SOUNDS := {
	SFX.WORD_TYPED: preload("res://assets/sfx/Minimalist13.ogg"),
	SFX.TYPO: preload("res://assets/sfx/Coffee1.ogg")
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func play_sfx(sfx: SFX):
	if SOUNDS.has(sfx):
		stream = SOUNDS[sfx]
		play()
	else:
		push_warning("No sfx found for: " + str(sfx))
