class_name LevelOrchestrator
extends Node3D


var level_params_dict = {
	1: LevelParameters.new({
		EnemyClassDB.EnemyClass.COMMON_WORD: EnemySpawnParameters.new(1.0)
	}, 3.0),
	2: LevelParameters.new({
		EnemyClassDB.EnemyClass.COMMON_WORD: EnemySpawnParameters.new(1.0)
	}, 1.5),
	3: LevelParameters.new({
		EnemyClassDB.EnemyClass.COMMON_PHRASE: EnemySpawnParameters.new(1.0)
	}, 5.0)
}

# enemy: enemy params, spawn freq., 
func get_level_parameters(level: int) -> LevelParameters:
	if level not in level_params_dict:
		return LevelParameters.new({
			EnemyClassDB.EnemyClass.COMMON_PHRASE: EnemySpawnParameters.new(1.0)
		}, 5.0 / (level / 3.0))
	return level_params_dict[level]
