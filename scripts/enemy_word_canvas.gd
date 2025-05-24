class_name EnemyWordCanvas
extends CanvasLayer

var panel_offset_y := 60

@onready var label_anchor: Marker3D = $"../Label Anchor"
@onready var cam := get_viewport().get_camera_3d()
@onready var word_panel: EnemyWordPanel = $VBoxContainer/EnemyWordPanel
@onready var v_box_container: VBoxContainer = $VBoxContainer

func set_word(word: String) -> void:
	word_panel.set_word(word)
	v_box_container.position = cam.unproject_position(label_anchor.global_position) \
		- Vector2(v_box_container.size.x / 2, panel_offset_y)
		
	v_box_container.size = word_panel.get_label().get_size() + Vector2(18, 18)

func _process(delta: float) -> void:
	v_box_container.position = cam.unproject_position(label_anchor.global_position) \
		- Vector2(v_box_container.size.x / 2, panel_offset_y)
	v_box_container.visible = cam.is_position_behind(label_anchor.global_position) == false

func get_word_panel() -> EnemyWordPanel:
	return word_panel

func _on_enemy_word_panel_word_typed(_word: String) -> void:
	visible = false
