class_name Level extends Node

@onready var enemy_spawn_points: Node = $EnemySpawnPoints

var _enemy_spawn_point_array: Array[EnemySpawnPoint] = []

@export var player_trans_path: Path3D

# TODO - make this class hold level param data as well, not just level transition data

func _ready():
	_enemy_spawn_point_array = []
	for child in enemy_spawn_points.get_children():
		if child is EnemySpawnPoint:
			_enemy_spawn_point_array.append(child)

func get_player_transition_path() -> Path3D:
	return player_trans_path

func get_enemy_spawn_points() -> Array[EnemySpawnPoint]:
	return _enemy_spawn_point_array
