class_name DamageVignette
extends TextureRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_disabled := false

func _on_enemy_damage_dealt(dmg: int):
	if not is_disabled:
		animation_player.play("flash_damage")
