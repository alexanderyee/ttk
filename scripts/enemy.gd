class_name Enemy
extends CharacterBody3D

@export var speed := 1.0
@export var max_distance_from_player := 1.5

var can_move := true

@onready var player: CharacterBody3D = $"../Player"


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if can_move:
		var vector_to_player := player.position - position
		can_move = vector_to_player.length() >= max_distance_from_player
		# move towards player
		if can_move:
			velocity = vector_to_player.normalized() * speed
		else:
			velocity = Vector3.ZERO
		move_and_slide()
	pass
