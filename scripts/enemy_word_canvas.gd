class_name EnemyWordCanvas
extends CanvasLayer

const ARROW_SPEED = 8.0
const DMG_DRAIN_SPEED = 7.0

@export var pulse_freq := .3
@export var panel_offset_y := 75


@onready var label_anchor: Marker3D = $"../Label Anchor"
@onready var cam: Camera3D = get_viewport().get_camera_3d()
@onready var word_panel: EnemyWordPanel = $VBoxContainer/EnemyWordPanel
@onready var v_box_container: VBoxContainer = $VBoxContainer

# health bar
@onready var health_bar_container: HBoxContainer = $VBoxContainer/Panel/VBoxContainer/MarginContainer/HealthBarContainer
@onready var current_health_bar: ColorRect = $VBoxContainer/Panel/VBoxContainer/MarginContainer/HealthBarContainer/CurrentHealth
@onready var damage_taken_bar: ColorRect = $VBoxContainer/Panel/VBoxContainer/MarginContainer/HealthBarContainer/DamageTaken
@onready var margin_container: MarginContainer = $VBoxContainer/Panel/VBoxContainer/MarginContainer


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
var is_taken_damage_done := false
var initial_damage_taken_width := 0.0
var damage_taken_bar_t = 0.0

func _ready() -> void:
	all_arrows = [top_left_active_arrow, bottom_left_active_arrow, top_right_active_arrow, bottom_right_active_arrow]
	arrow_offset = top_left_active_arrow.size / 2

func _process(delta: float) -> void:
	v_box_container.position = cam.unproject_position(label_anchor.global_position) \
		- Vector2(v_box_container.size.x / 2, panel_offset_y)
	v_box_container.visible = cam.is_position_behind(label_anchor.global_position) == false
	
	if is_active:
		animate_arrows(delta)
	
	animate_dmg_taken_health_bar(delta)

func set_word(word: String) -> void:
	word_panel.set_word(word)
	v_box_container.position = cam.unproject_position(label_anchor.global_position) \
		- Vector2(v_box_container.size.x / 2, panel_offset_y)
	await get_tree().process_frame
	health_bar_container.custom_minimum_size.x = word_panel.custom_minimum_size.x - margin_container.get_theme_constant("margin_left") - margin_container.get_theme_constant("margin_right")
	await get_tree().process_frame
	update_health(1, 1, 0)
	visible = true

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
	
# this function assumes damage_taken has already been subtracted from the current
func update_health(current: float, total: float, damage_taken: float = 0) -> void:
	var current_health_pct := current / total
	var dmg_pct := damage_taken / total
	var hbar_width := health_bar_container.size.x
	current_health_bar.custom_minimum_size.x = current_health_pct * hbar_width
	damage_taken_bar.custom_minimum_size.x = dmg_pct * hbar_width

# called whenever the damage that's currently being done to the enemy is
# finished. this func essentially just removes the red bar with lerp
func set_taken_damage_done() -> void:
	is_taken_damage_done = true
	initial_damage_taken_width = damage_taken_bar.custom_minimum_size.x

func animate_dmg_taken_health_bar(delta) -> void:
	if is_taken_damage_done:
		damage_taken_bar_t += delta
		var weight = 1 - exp(-DMG_DRAIN_SPEED * damage_taken_bar_t)
		damage_taken_bar.custom_minimum_size.x = initial_damage_taken_width * (1 - weight)
		if damage_taken_bar.custom_minimum_size.x <= 0.0:
			is_taken_damage_done = false
			damage_taken_bar_t = 0.0
			initial_damage_taken_width = 0.0

func get_word_panel() -> EnemyWordPanel:
	return word_panel

func _on_enemy_word_panel_word_typed(_word: String) -> void:
	for arrow: TextureRect in all_arrows:
		arrow.visible = false
	pass
	
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
