class_name LevelParameters
extends Node

var enemy_spawn_dict: Dictionary[EnemyClassDB.EnemyClass, EnemySpawnParameters]
var seconds_between_spawns: float

func _init(enemy_spawns: Dictionary[EnemyClassDB.EnemyClass, EnemySpawnParameters], s_between_spawns) -> void:
	enemy_spawn_dict = enemy_spawns
	seconds_between_spawns = s_between_spawns

func get_enemy_spawn_dict() -> Dictionary[EnemyClassDB.EnemyClass, EnemySpawnParameters]:
	return enemy_spawn_dict

func get_seconds_between_spawns() -> float:
	return seconds_between_spawns
