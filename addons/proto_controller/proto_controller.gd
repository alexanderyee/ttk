extends CharacterBody3D

@export var health := 100
## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var camera: Camera3D = $Head/Camera3D

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	pass

func _physics_process(delta: float) -> void:
	pass
	
func _on_enemy_spawner_word_added(enemy, word):
	enemy.damage_dealt.connect(_on_enemy_damage_dealt)
	
	
func _on_enemy_damage_dealt(dmg: int):
	health -= dmg
