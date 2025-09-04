class_name EnemyWordCanvas
extends CanvasLayer

const ARROW_SPEED = 8.0
const DEFAULT_HEALTH_BAR_WIDTH = 100.0

@export var pulse_freq := .3
@export var panel_offset_y := 100


@onready var label_anchor: Marker3D = $"../Label Anchor"
@onready var cam: Camera3D = get_viewport().get_camera_3d()

@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var completion_text: MarginContainer = $VBoxContainer/CompletionText
@onready var completion_text_label: RichTextLabel = $VBoxContainer/CompletionText/CompletionTextLabel
@onready var completion_text_anim_player: AnimationPlayer = $VBoxContainer/CompletionText/CompletionTextAnimPlayer

@onready var word_panel_placeholder: Control = $VBoxContainer/WordPanelPlaceholder
@onready var word_panel: EnemyWordPanel = $VBoxContainer/EnemyWordPanel

# health bar 
@onready var health_bar_panel: Panel = $VBoxContainer/HealthBarPanel

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
	word_panel.connect("word_panel_visibility_changed", _on_word_panel_vis_changed)
	all_arrows = [top_left_active_arrow, bottom_left_active_arrow, top_right_active_arrow, bottom_right_active_arrow]
	arrow_offset = top_left_active_arrow.size / 2

func _process(delta: float) -> void:
	v_box_container.position = cam.unproject_position(label_anchor.global_position) \
		- Vector2(v_box_container.size.x / 2, panel_offset_y)
	v_box_container.visible = cam.is_position_behind(label_anchor.global_position) == false
	
	if is_active:
		animate_arrows(delta)
		
	# TODO: not best practice, manage state of word panel of UI
	if !completion_text.visible and !word_panel.visible:
		word_panel_placeholder.visible = true
	else:
		word_panel_placeholder.visible = false

func set_word_completed_text(typo_count: int) -> void:
	completion_text.visible = true
	completion_text_label.modulate = Color(1, 1, 1, 1)
	completion_text_label.scale = Vector2.ONE
	if typo_count > 0:
		completion_text_label.text = "[center]" +  "OK" + "[/center]"
	else:
		completion_text_label.text = "[center][i]" + "PERFECT!" + "[/i][/center]"
	completion_text_anim_player.play("pop_fade")
	

func set_word(word: String) -> void:
	word_panel.set_word(word)
	v_box_container.position = cam.unproject_position(label_anchor.global_position) \
		- Vector2(v_box_container.size.x / 2, panel_offset_y)
	await get_tree().process_frame
	visible = true

func set_active(active: bool = true) -> void:
	is_active = active
	word_panel.set_active(active)

	if active:
		layer = 2
		# set positions of arrows to corners of container
		top_left_active_arrow.position = v_box_container.position - arrow_offset
		top_right_active_arrow.position = v_box_container.position + Vector2(v_box_container.size.x, 0) - arrow_offset
		bottom_right_active_arrow.position = v_box_container.position + v_box_container.size - arrow_offset
		bottom_left_active_arrow.position = v_box_container.position + Vector2(0, v_box_container.size.y) - arrow_offset
		for arrow: TextureRect in all_arrows:
			arrow.visible = true
		active_arrow_pulse_timer.start(pulse_freq)
	else:
		layer = 1
		# hide arrows
		for arrow: TextureRect in all_arrows:
			arrow.visible = false
	

func update_total_health(health: float, health_bar_width: float):
	health_bar_panel.set_total_health(health)
	health_bar_panel.set_max_width(health_bar_width)

# this function assumes damage_taken has already been subtracted from the current
func update_health(current: float, total: float, damage_taken: float = 0) -> void:
	await get_tree().process_frame
	update_total_health(total, DEFAULT_HEALTH_BAR_WIDTH)
	health_bar_panel.update_health_bar(current, damage_taken)

# called whenever the damage that's currently being done to the enemy is
# finished
func set_taken_damage_done() -> void:
	health_bar_panel.set_dmg_taken_done()

func get_word_panel() -> EnemyWordPanel:
	return word_panel

func _on_enemy_word_panel_word_typed(_word: String) -> void:
	set_active(false)
	
func _on_word_panel_vis_changed(vis: bool) -> void:
	word_panel_placeholder.custom_minimum_size.y = word_panel.size.y
	completion_text.custom_minimum_size.y = word_panel.size.y
	if vis:
		word_panel_placeholder.visible = false

func _on_active_arrow_pulse_timer_timeout() -> void:
	arrow_pulse_outwards = !arrow_pulse_outwards

func animate_arrows(delta) -> void:
	var weight = 1 - exp(-ARROW_SPEED * delta)
	var pos_offset_factor := 2
	
	var top_left_dir = word_panel.global_position - arrow_offset
	if arrow_pulse_outwards:
		top_left_dir -= arrow_offset * pos_offset_factor
	top_left_active_arrow.position = top_left_active_arrow.position.lerp(
		top_left_dir, weight)
	
	var top_right_dir = word_panel.global_position + Vector2(word_panel.size.x, 0) - arrow_offset
	if arrow_pulse_outwards:
		top_right_dir -= (arrow_offset * pos_offset_factor * Vector2(-1, 1))
	top_right_active_arrow.position = top_right_active_arrow.position.lerp(top_right_dir, weight)
	
	var bottom_right_dir = word_panel.global_position + word_panel.size - arrow_offset
	if arrow_pulse_outwards:
		bottom_right_dir -= arrow_offset * pos_offset_factor * Vector2(-1, -1)
	bottom_right_active_arrow.position = bottom_right_active_arrow.position.lerp(bottom_right_dir, weight)
	
	var bottom_left_dir = word_panel.global_position + Vector2(0, word_panel.size.y) - arrow_offset
	if arrow_pulse_outwards:
		bottom_left_dir -= arrow_offset * pos_offset_factor * Vector2(1, -1)
	bottom_left_active_arrow.position = bottom_left_active_arrow.position.lerp(bottom_left_dir, weight)


func _on_completion_text_anim_finished(anim_name: StringName) -> void:
	if anim_name == "pop_fade":
		word_panel_placeholder.visible = true
		completion_text.visible = false
