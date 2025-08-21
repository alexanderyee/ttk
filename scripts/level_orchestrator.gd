class_name LevelOrchestrator
extends Node3D
 
@onready var level_1: Level = $Level1
@onready var level_2: Level = $Level2
@onready var level_3: Level = $Level3
@onready var level_4: Level = $Level4

var level_scene_list: Array[Level]

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
	level_scene_list = [level_1, level_2, level_3, level_4]
	
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

func get_enemy_spawn_points(level: int) -> Array[EnemySpawnPoint]:
	var level_node: Level = get_node("Level" + str(level))
	if not level_node:
		push_error("Level %d not found!" % level)
		return []
	return level_node.get_enemy_spawn_points()

func transition_player_from_level(level: int) -> void:
	var level_scene: Level = level_scene_list[level]
	var level_transition_path: Path3D = level_scene.get_player_transition_path()
	await transition_player_with_rotation(level_transition_path, Global.LEVEL_COUNTDOWN_TIME, level_scene.player_trans_path_face_forward)

func transition_player_with_rotation(path: Path3D, duration: float = 3.0, face_forward: bool = false):
	var path_follow = PathFollow3D.new()
	path_follow.rotation_mode = PathFollow3D.ROTATION_Y if face_forward else PathFollow3D.ROTATION_NONE    # Auto-rotate to face path direction
	path.add_child(path_follow)

	# Reparent player
	var player: Player = get_tree().get_first_node_in_group("player")
	var original_parent = player.get_parent()
	player.reparent(path_follow)
	# Set initial position
	player.global_position = path.global_position
	player.global_rotation = path.global_rotation
	# Animate
	var tween = create_tween()
	tween.tween_property(path_follow, "progress_ratio", 1.0, duration)

	await tween.finished

	# Restore
	player.reparent(original_parent)
	path_follow.queue_free()
