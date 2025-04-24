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
		can_move = (player.position - position).length() >= max_distance_from_player
		# move towards player
		if can_move:
			var move_dir := (player.position - position).normalized()
			velocity = move_dir * speed
		else:
			velocity = Vector3.ZERO
		move_and_slide()
	pass
