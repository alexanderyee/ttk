class_name EnemySpawner
extends Node3D

signal word_added(enemy, word)

const ENEMY_SCENE = preload("res://scenes/enemy.tscn")
const ENEMY_CENTER_OFFSET = 1.0

var enemies_to_spawn: Dictionary[EnemyClassDB.EnemyClass, EnemySpawnParameters]
var enemies_spawned: Dictionary[EnemyClassDB.EnemyClass, int] = {}
@export var seconds_between_spawns := 1.5
@export var spawn_area_width = 20.0
@export var spawn_area_height = 4.7
@onready var timer: Timer = $Timer
@onready var enemy_shapecast: ShapeCast3D = $ShapeCast3D
@onready var player: CharacterBody3D = $"../Player"
@onready var level_orchestrator: LevelOrchestrator = $"../LevelOrchestrator"

func _ready() -> void:
	timer.wait_time = seconds_between_spawns
	connect("word_added", WordBank._on_enemy_spawner_word_added)

func _process(delta: float) -> void:
	pass

func stop() -> void:
	timer.stop()
	
func start() -> void:
	# adjust params for new lvl
	var level_params: LevelParameters = level_orchestrator.get_level_parameters(PlayerStats.get_current_level())
	enemies_to_spawn = level_params.get_enemy_spawn_dict()
	seconds_between_spawns = level_params.get_seconds_between_spawns()
	# start spawning enemies again
	_on_timer_timeout()
	timer.start(seconds_between_spawns)

func _on_timer_timeout() -> void:
	var enemy := ENEMY_SCENE.instantiate()
	# randomize positions until we find a place to spawn
	var enemy_spawn_position := position
	var new_spawn_pos_valid := false
	var num_spawn_attempts := 0
	
	while not new_spawn_pos_valid and num_spawn_attempts < 1000: # TODO handle this some other way
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
		enemy.damage = enemy_stats.damage
		enemy.health = enemy_stats.health
		enemy.damage_cycle_time = enemy_stats.damage_cycle_time
		add_sibling(enemy)
		
		# add enemy to our spawn history
		if enemy_class not in enemies_spawned:
			enemies_spawned[enemy_class] = 1
		else:
			enemies_spawned[enemy_class] += 1
			
		# get word from word bank
		var word = WordBank.get_random_word(enemy_stats.is_phrase)
		word_added.emit(enemy, word)
	else:
		push_warning("New enemy wasn't able to spawn after %d attempts!" % num_spawn_attempts)
		enemy.queue_free()
	

func get_enemy_class() -> EnemyClassDB.EnemyClass:
	var spawnable_enemies = enemies_to_spawn.keys()
	
	# check if we've hit our limit for any of these enemies, if so remove from
	# possible list of enemies to spawn
	var enemies_to_remove = []
	for enemy_class in enemies_to_spawn:
		if enemy_class in enemies_spawned and \
			enemies_spawned[enemy_class] >= enemies_to_spawn[enemy_class].limit:
				
			enemies_to_remove.append(enemy_class)
			
	for e in enemies_to_remove:
		spawnable_enemies.erase(e)
	
	# roll for an enemy to spawn
	var result: EnemyStats
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
