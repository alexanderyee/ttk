class_name LevelOrchestrator
extends Node3D

# eventually we want to store enemies and bosses as resources and have this class
# orchestrate a level by dictating what kind of enemies can spawn, how often they
# spawn, and what modifiers they have (damage, health)

var LEVEL_PARAMS_DICT = {
	1: LevelParameters.new({}, 1.0)
}

# enemy: enemy params, spawn freq., 
func get_level_parameters(level: int) -> LevelParameters:
	return LEVEL_PARAMS_DICT[level]
