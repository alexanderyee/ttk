class_name EnemySpawnParameters
extends Node

const INT64_MAX = 9223372036854775807

# % chance this enemy can spawn in the level
var probability: float

# max no. of this type of enemy that can spawn in one level
var limit: int

func _init(prob: float, lim: int = INT64_MAX) -> void:
	probability = prob
	limit = lim
