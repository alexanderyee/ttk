class_name EnemyWordsUI
extends CanvasLayer

const ENEMY_WORD_PANEL_SCENE = preload("res://scenes/enemy_word_panel.tscn")

var enemy_word_panels := {}

@onready var cam := get_viewport().get_camera_3d()

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	for enemy in enemy_word_panels:
		# update label position
		var enemy_label_anchor : Marker3D = enemy.get_label_anchor()
		enemy_word_panels[enemy].position = cam.unproject_position(enemy_label_anchor.global_position) \
			- Vector2(enemy_word_panels[enemy].size.x / 2, 30)
		enemy_word_panels[enemy].visible = cam.is_position_behind(enemy_label_anchor.global_position) == false

func _on_enemy_spawner_word_added(enemy: Enemy, word: String):
	var enemy_label_anchor : Marker3D = enemy.get_label_anchor()
	var enemy_word_panel : EnemyWordPanel = ENEMY_WORD_PANEL_SCENE.instantiate()
	enemy_word_panel.set_word(word)
	enemy_word_panel.word_typed.connect(_on_enemy_word_typed)
	add_child(enemy_word_panel)
	var enemy_word_label = enemy_word_panel.get_label()
	
	# TODO deduplicate
	enemy_word_panel.position = cam.unproject_position(enemy_label_anchor.global_position) \
		- Vector2(enemy_word_panel.size.x / 2, 30)
	enemy_word_panel.size = enemy_word_label.get_size() + Vector2(10, 10)
	enemy_word_panels[enemy] = enemy_word_panel

func get_enemy_word_panels_dict() -> Dictionary:
	return enemy_word_panels
	
func _on_enemy_word_typed(word: String):
	for enemy: Enemy in enemy_word_panels:
		if enemy_word_panels[enemy].get_word() == word:
			despawn_enemy(enemy)
			
func despawn_enemy(enemy: Enemy):
	enemy_word_panels[enemy].queue_free()
	enemy_word_panels.erase(enemy)
	enemy.queue_free()
