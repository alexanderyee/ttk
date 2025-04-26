extends Node3D

# TODO
# think about how to generate enemies, make enemies of varying difficulties resources? 
signal word_added(enemy, word)
const ENEMY_SCENE = preload("res://scenes/enemy.tscn")
@export var time_between_spawn_seconds := 3.0
@export var spawn_area_width = 20.0
@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.wait_time = time_between_spawn_seconds

func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	var enemy = ENEMY_SCENE.instantiate()
	# randomize position laterally
	var enemy_spawn_position = position
	enemy_spawn_position.x += Global.rng.randf_range(spawn_area_width / 2 * -1, spawn_area_width / 2)
	enemy.position = enemy_spawn_position
	add_sibling(enemy)
	
	# get word from word bank
	var word = WordBank.get_random_word().to_lower()
	word = "[center]" + word + "[/center]"
	word_added.emit(enemy, word)
