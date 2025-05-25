class_name EnemyWordCanvas
extends CanvasLayer

const ARROW_SPEED = 8.0

@export var pulse_freq := .3
@export var panel_offset_y := 75


@onready var label_anchor: Marker3D = $"../Label Anchor"
@onready var cam := get_viewport().get_camera_3d()
@onready var word_panel: EnemyWordPanel = $VBoxContainer/EnemyWordPanel
@onready var v_box_container: VBoxContainer = $VBoxContainer

# arrows for showing enemy panel is active
@onready var top_left_active_arrow: TextureRect = $TopLeftActiveArrow
@onready var bottom_left_active_arrow: TextureRect = $BottomLeftActiveArrow
@onready var top_right_active_arrow: TextureRect = $TopRightActiveArrow
@onready var bottom_right_active_arrow: TextureRect = $BottomRightActiveArrow
@onready var active_arrow_pulse_timer: Timer = $ActiveArrowPulseTimer

var is_active := false
var arrow_pulse_outwards := true
var all_arrows: Array[TextureRect]
var arrow_offset: Vector2

func _ready() -> void:
	all_arrows = [top_left_active_arrow, bottom_left_active_arrow, top_right_active_arrow, bottom_right_active_arrow]
	arrow_offset = top_left_active_arrow.size / 2

func set_word(word: String) -> void:
	word_panel.set_word(word)
	v_box_container.position = cam.unproject_position(label_anchor.global_position) \
		- Vector2(v_box_container.size.x / 2, panel_offset_y)
		
	visible = true

func _process(delta: float) -> void:
	v_box_container.position = cam.unproject_position(label_anchor.global_position) \
		- Vector2(v_box_container.size.x / 2, panel_offset_y)
	v_box_container.visible = cam.is_position_behind(label_anchor.global_position) == false
	
	if is_active:
		animate_arrows(delta)
	

func set_active() -> void:
	is_active = true
	# set positions of arrows to corners of container
	top_left_active_arrow.position = v_box_container.position - arrow_offset
	top_right_active_arrow.position = v_box_container.position + Vector2(v_box_container.size.x, 0) - arrow_offset
	bottom_right_active_arrow.position = v_box_container.position + v_box_container.size - arrow_offset
	bottom_left_active_arrow.position = v_box_container.position + Vector2(0, v_box_container.size.y) - arrow_offset
	for arrow: TextureRect in all_arrows:
		arrow.visible = true
	active_arrow_pulse_timer.start(pulse_freq)
	

func get_word_panel() -> EnemyWordPanel:
	return word_panel

func _on_enemy_word_panel_word_typed(_word: String) -> void:
	visible = false
	
func _on_active_arrow_pulse_timer_timeout() -> void:
	arrow_pulse_outwards = !arrow_pulse_outwards

func animate_arrows(delta) -> void:
	var weight = 1 - exp(-ARROW_SPEED * delta)
	var pos_offset_factor := 2
	
	var top_left_dir = v_box_container.position - arrow_offset
	if arrow_pulse_outwards:
		top_left_dir -= arrow_offset * pos_offset_factor
	top_left_active_arrow.position = top_left_active_arrow.position.lerp(
		top_left_dir, weight)
	
	var top_right_dir = v_box_container.position + Vector2(v_box_container.size.x, 0) - arrow_offset
	if arrow_pulse_outwards:
		top_right_dir -= (arrow_offset * pos_offset_factor * Vector2(-1, 1))
	top_right_active_arrow.position = top_right_active_arrow.position.lerp(top_right_dir, weight)
	
	var bottom_right_dir = v_box_container.position + v_box_container.size - arrow_offset
	if arrow_pulse_outwards:
		bottom_right_dir -= arrow_offset * pos_offset_factor * Vector2(-1, -1)
	bottom_right_active_arrow.position = bottom_right_active_arrow.position.lerp(bottom_right_dir, weight)
	
	var bottom_left_dir = v_box_container.position + Vector2(0, v_box_container.size.y) - arrow_offset
	if arrow_pulse_outwards:
		bottom_left_dir -= arrow_offset * pos_offset_factor * Vector2(1, -1)
	bottom_left_active_arrow.position = bottom_left_active_arrow.position.lerp(bottom_left_dir, weight)
