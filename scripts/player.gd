class_name Player
extends CharacterBody3D

@export var total_health := 100
var health := total_health 

@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var camera: PlayerCamera = $Head/Camera3D

func _physics_process(_delta: float) -> void:
	pass

# returns true if player died
func damage_dealt(dmg: int) -> bool:
	if health <= 0:
		# player is already dead
		return true
	health -= dmg
	camera.add_trauma(0.5)
	return health <= 0

func get_current_health() -> int:
	return health

func get_total_health() -> int:
	return total_health
