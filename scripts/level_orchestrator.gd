class_name LevelOrchestrator
extends Node3D

enum EnemyClass {COMMON_WORD, TANK_WORD, COMMON_PHRASE}

# eventually we want to store enemies and bosses as resources and have this class
# orchestrate a level by dictating what kind of enemies can spawn, how often they
# spawn, and what modifiers they have (damage, health)

var common_word = preload("res://resources/enemies/common_word_enemy.tres")
var tank_word = preload("res://resources/enemies/tank_word_enemy.tres")
var common_phrase = preload("res://resources/enemies/common_phrase_enemy.tres")

var level_params_dict = {
	1: LevelParameters.new({
		common_word: EnemySpawnParameters.new(1.0)
	}, 3.0),
	2: LevelParameters.new({
		common_word: EnemySpawnParameters.new(1.0)
	}, 1.5),
	3: LevelParameters.new({
		common_phrase: EnemySpawnParameters.new(1.0)
	}, 5.0)
}

# enemy: enemy params, spawn freq., 
func get_level_parameters(level: int) -> LevelParameters:
	return level_params_dict[level]
