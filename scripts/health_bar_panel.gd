class_name HealthBarPanel 
extends Panel

# this class, given a height and max_width, represents a health bar with
# a current health bar (yellow) and current damage taken bar (red)

const DMG_DRAIN_SPEED = 7.0

@export var height: float = 20.0

var total_health := 1.0
var is_taken_dmg_done := false
var initial_dmg_taken_width := 0.0
var dmg_taken_bar_t = 0.0
var health_bar_width = custom_minimum_size.x

@onready var health_bar_container: HBoxContainer = $MarginContainer/HealthBarContainer
@onready var curr_health_bar: ColorRect = $MarginContainer/HealthBarContainer/CurrentHealth
@onready var dmg_taken_bar: ColorRect = $MarginContainer/HealthBarContainer/DamageTaken
@onready var margin_container: MarginContainer = $MarginContainer


func _ready() -> void:
	custom_minimum_size.y = height

func _process(delta):
	animate_dmg_taken_health_bar(delta)

func set_total_health(health: float) -> void:
	total_health = health

func set_max_width(width: float) -> void:
	custom_minimum_size.x = width
	health_bar_width = width - margin_container.get_theme_constant("margin_left") - \
		margin_container.get_theme_constant("margin_right")

func update_health_bar(curr_health: float, dmg_taken: float):
	curr_health_bar.custom_minimum_size.x = curr_health / total_health * health_bar_width
	dmg_taken_bar.custom_minimum_size.x = dmg_taken / total_health * health_bar_width

func set_dmg_taken_done() -> void:
	is_taken_dmg_done = true
	initial_dmg_taken_width = dmg_taken_bar.custom_minimum_size.x

# removes the red bar with lerp
func animate_dmg_taken_health_bar(delta) -> void:
	if is_taken_dmg_done:
		dmg_taken_bar_t += delta
		var weight = 1 - exp(-DMG_DRAIN_SPEED * dmg_taken_bar_t)
		dmg_taken_bar.custom_minimum_size.x = initial_dmg_taken_width * (1 - weight)
		if dmg_taken_bar.custom_minimum_size.x <= 0.0:
			is_taken_dmg_done = false
			dmg_taken_bar_t = 0.0
			initial_dmg_taken_width = 0.0
