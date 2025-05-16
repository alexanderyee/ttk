class_name DamageVignette
extends TextureRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_enemy_damage_dealt(dmg: int):
	animation_player.play("flash_damage")
