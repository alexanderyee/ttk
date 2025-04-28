class_name SFXPlayer
extends AudioStreamPlayer

@export var typo_sfx_cooldown_s = 1.0
@onready var typo_sfx_cooldown_timer: Timer = $TypoSFXCooldown

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
		# since it's likely people will make several keystroke errors in succession, we limit 
		# the # of typo sfx being played per second
		if sfx == SFX.TYPO and not typo_sfx_cooldown_timer.is_stopped():
			return
		elif sfx == SFX.TYPO:
			typo_sfx_cooldown_timer.start(typo_sfx_cooldown_s)
		stream = SOUNDS[sfx]
		play()
	else:
		push_warning("No sfx found for: " + str(sfx))


func _on_typo_sfx_cooldown_timeout() -> void:
	typo_sfx_cooldown_timer.stop()
