class_name LevelOrchestrator
extends Node3D


var level_params_dict = {
	1: LevelParameters.new({
		EnemyClassDB.EnemyClass.COMMON_WORD: EnemySpawnParameters.new(1.0)
	}, 2.5 if not Global.DEBUG_MODE else 2.5),
	2: LevelParameters.new({
		EnemyClassDB.EnemyClass.TANK_WORD: EnemySpawnParameters.new(1.0)
	}, 4.5),
	3: LevelParameters.new({
		EnemyClassDB.EnemyClass.COMMON_PHRASE: EnemySpawnParameters.new(1.0)
	}, 4.5),
	4:  LevelParameters.new({
		EnemyClassDB.EnemyClass.AGILE_WORD: EnemySpawnParameters.new(1.0)
	}, 1.25),
	5: LevelParameters.new({
		EnemyClassDB.EnemyClass.AGILE_WORD: EnemySpawnParameters.new(.5),
		EnemyClassDB.EnemyClass.AGILE_PHRASE: EnemySpawnParameters.new(.5)
	}, 2.5),
}

# enemy: enemy params, spawn freq., 
func get_level_parameters(level: int) -> LevelParameters:
	if level not in level_params_dict:
		return LevelParameters.new({
			EnemyClassDB.EnemyClass.AGILE_WORD: EnemySpawnParameters.new(.25),
			EnemyClassDB.EnemyClass.AGILE_PHRASE: EnemySpawnParameters.new(.25),
			EnemyClassDB.EnemyClass.TANK_WORD: EnemySpawnParameters.new(.25),
			EnemyClassDB.EnemyClass.COMMON_PHRASE: EnemySpawnParameters.new(.125),
			EnemyClassDB.EnemyClass.TANK_PHRASE: EnemySpawnParameters.new(.125)
		}, 2.5 / (level / 4.0))
	return level_params_dict[level]
