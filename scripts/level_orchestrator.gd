class_name LevelOrchestrator
extends Node3D
 
@onready var level_1: Level = $Level1
@onready var level_2: Level = $Level2

var transition_paths: Dictionary[String, Path3D]

var level_params_dict: Dictionary[int, LevelParameters] = {
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

func _ready() -> void:
	transition_paths = {
		"0_to_1": level_1.get_player_transition_path(),
		"1_to_2": level_2.get_player_transition_path()
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

func transition_player_from_level(level: int) -> void:
	var transition_path_key = str(level) + "_to_" + str(level + 1)
	var level_transition_path: Path3D = transition_paths[transition_path_key]
	await transition_player_with_rotation(level_transition_path)

func transition_player_with_rotation(path: Path3D, duration: float = 3.0, face_forward: bool = false):
	var path_follow = PathFollow3D.new()
	path_follow.rotation_mode = PathFollow3D.ROTATION_XYZ if face_forward else PathFollow3D.ROTATION_NONE    # Auto-rotate to face path direction
	path.add_child(path_follow)

	# Reparent player
	var player: Player = get_tree().get_first_node_in_group("player")
	var original_parent = player.get_parent()
	player.reparent(path_follow)

	# Animate
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(path_follow, "progress_ratio", 1.0, duration)

	await tween.finished

	# Restore
	player.reparent(original_parent)
	path_follow.queue_free()
