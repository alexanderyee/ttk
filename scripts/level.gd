class_name Level extends Node

@onready var player_trans_path: Path3D = $Path3D
@onready var enemy_spawn_points: Node = $EnemySpawnPoints

# TODO - make this class hold level param data as well, not just level transition data

func get_player_transition_path() -> Path3D:
	return player_trans_path

func get_enemy_spawn_points() -> Array[EnemySpawnPoint]:
	return enemy_spawn_points.get_children().filter(func(node: Node) -> bool:
		return node is EnemySpawnPoint)
