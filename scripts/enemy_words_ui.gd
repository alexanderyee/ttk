extends CanvasLayer

const ENEMY_WORD_SCENE = preload("res://scenes/enemy_word.tscn")

var enemy_word_labels := {}

@onready var cam := get_viewport().get_camera_3d()


func _ready() -> void:
	
	pass # Replace with function body.

func _process(delta: float) -> void:
	for enemy in enemy_word_labels:
		# update label position
		var enemy_label_anchor : Marker3D = enemy.get_label_anchor()
		enemy_word_labels[enemy].position = cam.unproject_position(enemy_label_anchor.global_position) \
			- Vector2(enemy_word_labels[enemy].size.x / 2, 30)
		enemy_word_labels[enemy].visible = cam.is_position_behind(enemy_label_anchor.global_position) == false

func add_enemy_word(enemy: Enemy, label: Panel):
	enemy_word_labels[enemy] = label
	
func remove_enemy_word(enemy: Enemy) -> bool:
	return enemy_word_labels.erase(enemy)

func _on_enemy_spawner_word_added(enemy: Enemy, word: String):
	var enemy_label_anchor : Marker3D = enemy.get_label_anchor()
	var enemy_word_scene = ENEMY_WORD_SCENE.instantiate()
	var enemy_word_label = enemy_word_scene.get_child(0)
	# TODO deduplicate
	enemy_word_label.text = word
	enemy_word_scene.position = cam.unproject_position(enemy_label_anchor.global_position) \
		- Vector2(enemy_word_scene.size.x / 2, 30)
	add_child(enemy_word_scene)
	add_enemy_word(enemy, enemy_word_scene)
