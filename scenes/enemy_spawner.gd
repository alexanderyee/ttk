extends Node3D

# TODO
# think about how to generate enemies, make enemies of varying difficulties resources? 
signal word_added(enemy, word)

const ENEMY_SCENE = preload("res://scenes/enemy.tscn")
const ENEMY_CENTER_OFFSET = 1.0

@export var time_between_spawn_seconds := 1.5
@export var spawn_area_width = 20.0
@export var spawn_area_height = 4.7
@onready var timer: Timer = $Timer
@onready var enemy_shapecast: ShapeCast3D = $ShapeCast3D

func _ready() -> void:
	timer.wait_time = time_between_spawn_seconds
	

func _process(delta: float) -> void:
	pass


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
		add_sibling(enemy)
		# get word from word bank
		var word = WordBank.get_random_word().to_lower()
		word_added.emit(enemy, word)
	else:
		push_error("New enemy wasn't able to spawn after %d attempts!" % num_spawn_attempts)
		enemy.queue_free()
	
