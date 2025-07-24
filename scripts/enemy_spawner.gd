class_name EnemySpawner
extends Node3D

signal enemy_spawned(enemy: Enemy)

const ENEMY_SCENE = preload("res://scenes/enemy.tscn")
const ENEMY_CENTER_OFFSET = 1.0
const ENEMY_Y_SORT_BAND_HEIGHT = 40.0

var enemies_to_spawn: Dictionary[EnemyClassDB.EnemyClass, EnemySpawnParameters]
var enemy_class_spawned_count: Dictionary[EnemyClassDB.EnemyClass, int] = {}
var enemy_word_panels: Dictionary[Enemy, EnemyWordPanel] = {}

@export var seconds_between_spawns := 1.5
@export var spawn_area_width = 16.0
@export var spawn_area_height = 4.7
@onready var timer: Timer = $Timer
@onready var enemy_shapecast: ShapeCast3D = $ShapeCast3D
@onready var level_orchestrator: LevelOrchestrator = $"../LevelOrchestrator"
@onready var cam: Camera3D = get_viewport().get_camera_3d()

func _ready() -> void:
	timer.wait_time = seconds_between_spawns

func _process(_delta: float) -> void:
	pass

func stop() -> void:
	timer.stop()

func start() -> void:
	# adjust params for new lvl
	var level_params: LevelParameters = level_orchestrator.get_level_parameters(PlayerStats.get_current_level())
	enemies_to_spawn = level_params.get_enemy_spawn_dict()
	seconds_between_spawns = level_params.get_seconds_between_spawns()
	# start spawning enemy_word_panels again
	_on_timer_timeout()
	timer.start(seconds_between_spawns)

func _on_timer_timeout() -> void:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	# randomize positions until we find a place to spawn
	var enemy_spawn_position := position
	var new_spawn_pos_valid := false
	var num_spawn_attempts := 0

	while not new_spawn_pos_valid and num_spawn_attempts < 10000: # TODO handle this some other way
		enemy_spawn_position = position
		enemy_spawn_position.x += Global.rng.randf_range(spawn_area_width / 2 * -1, spawn_area_width / 2)
		enemy_spawn_position.y += Global.rng.randf_range(0, spawn_area_height)
		# check if anything is colliding with where the new enemy would spawn
		# TODO instead of using ENEMY_CENTER_OFFSET we should go up halfway the enemy's collisionshape
		enemy_shapecast.global_position = enemy_spawn_position + Vector3.UP * ENEMY_CENTER_OFFSET
		enemy_shapecast.force_shapecast_update()
		if not enemy_shapecast.is_colliding():
			new_spawn_pos_valid = true
		num_spawn_attempts += 1

	if new_spawn_pos_valid:
		enemy.position = enemy_spawn_position
		# pick enemy stats
		var enemy_class: EnemyClassDB.EnemyClass = get_enemy_class()
		var enemy_stats = EnemyClassDB.get_enemy_stats(enemy_class)
		enemy.word_tag = enemy_stats.word_tag
		enemy.word_cycle_time = enemy_stats.word_cycle_time
		enemy.damage = enemy_stats.damage

		enemy.damage_cycle_time = enemy_stats.damage_cycle_time
		enemy.connect("enemy_died", _on_enemy_died)
		add_sibling(enemy)
		enemy_spawned.emit(enemy)
		if not enemy.is_word_set:
			enemy.set_word()
		var enemy_word = enemy.get_word()
		enemy.total_health = enemy_stats.health if enemy_word.length() < enemy_stats.health else enemy_word.length()
		enemy.current_health = enemy.total_health
		enemy.get_word_canvas().update_health(1, 1, 0) # update health ui

		## add enemy to our spawn history
		if enemy_class not in enemy_class_spawned_count:
			enemy_class_spawned_count[enemy_class] = 1
		else:
			enemy_class_spawned_count[enemy_class] += 1
		enemy_word_panels[enemy] = enemy.get_word_panel()

	else:
		push_warning("New enemy wasn't able to spawn after %d attempts!" % num_spawn_attempts)
		enemy.queue_free()


func get_enemy_class() -> EnemyClassDB.EnemyClass:
	var spawnable_enemies = enemies_to_spawn.keys()

	# check if we've hit our limit for any of these enemy_word_panels, if so remove from
	# possible list of enemy_word_panels to spawn
	var enemies_to_remove = []
	for enemy_class in enemies_to_spawn:
		if enemy_class in enemy_class_spawned_count and \
			enemy_class_spawned_count[enemy_class] >= enemies_to_spawn[enemy_class].limit:

			enemies_to_remove.append(enemy_class)

	for e in enemies_to_remove:
		spawnable_enemies.erase(e)

	# roll for an enemy to spawn
	var chance_for_enemies := {}
	var probability_counter := 0.0
	var probabilities = []
	for enemy_stats in spawnable_enemies:
		probability_counter += enemies_to_spawn[enemy_stats].probability
		chance_for_enemies[probability_counter] = enemy_stats
		probabilities.append(probability_counter)

	var roll := Global.rng.randf_range(0.0, probability_counter)

	for prob in probabilities:
		if roll <= prob:
			return chance_for_enemies[prob]
	push_error("Unable to roll for EnemyStats")
	return EnemyClassDB.EnemyClass.NULL

func get_enemy_word_panel_from_enemy(enemy: Enemy) -> EnemyWordPanel:
	return enemy_word_panels[enemy]

func get_enemy_word_panels_dict() -> Dictionary[Enemy, EnemyWordPanel]:
	return enemy_word_panels

# returns the dict of enemies -> their word panels, filtering
# out any enemies that don't a word yet 
func get_words_set_enemy_word_panels_dict() -> Dictionary[Enemy, EnemyWordPanel]:
	var result: Dictionary[Enemy, EnemyWordPanel] = {}
	var words_set_enemies = enemy_word_panels.keys().filter(func(enemy: Enemy): return enemy.is_word_set)
	for enemy in words_set_enemies:
		result[enemy] = enemy_word_panels[enemy]
	return result

func get_enemies_sorted_by_pos() -> Array[Enemy]:
	var sorted_enemies_by_pos = enemy_word_panels.keys().filter(func(enemy):
		return enemy.is_word_set)

	sorted_enemies_by_pos.sort_custom(func(a, b):
		var a_pos = cam.unproject_position(a.global_position)
		var b_pos = cam.unproject_position(b.global_position)

		if abs(a_pos.y - b_pos.y) > ENEMY_Y_SORT_BAND_HEIGHT:
			return a_pos.y < b_pos.y

		return a_pos.x < b_pos.x
	)
	
	return sorted_enemies_by_pos


func _on_enemy_died(enemy: Enemy) -> void:
	enemy_word_panels.erase(enemy)
