class_name LevelParameters
extends Node

var enemies: Dictionary[Enemy, EnemySpawnParameters]
var time_between_spawns_s: float

func _init(enemies_dict: Dictionary[Enemy, EnemySpawnParameters], time_between_spawns) -> void:
	enemies = enemies_dict
	time_between_spawns_s = time_between_spawns
