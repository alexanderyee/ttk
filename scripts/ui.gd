class_name UI
extends CanvasLayer

var original_health_bar_width : float
@onready var level_label: RichTextLabel = $"StatsMarginContainer/VBoxContainer/Level Label"
@onready var wpm_label: RichTextLabel = $"StatsMarginContainer/VBoxContainer/WPM Label"
@onready var words_typed_label: RichTextLabel = $"StatsMarginContainer/VBoxContainer/WordsTyped Label"
@onready var ttk_label: RichTextLabel = $"StatsMarginContainer/VBoxContainer/TTK Label"
@onready var accuracy_label: RichTextLabel = $"StatsMarginContainer/VBoxContainer/Accuracy Label"
@onready var health_label: RichTextLabel = $HealthLabelContainer/HealthLabel
@onready var health_bar_container: MarginContainer = $HealthBarContainer
@onready var level_time_label: RichTextLabel = $TimerMarginContainer/LevelTimeLabel
@onready var stats_margin_container: MarginContainer = $StatsMarginContainer
@onready var timer_margin_container: MarginContainer = $TimerMarginContainer
@onready var damage_vignette: DamageVignette = $DamageVignette

func _ready() -> void:
	original_health_bar_width = health_bar_container.custom_minimum_size.x
	
func update_level(level: int):
	level_label.text = "Level: " + str(level)
	
func update_wpm(wpm: int):
	wpm_label.text = "WPM: " + str(wpm)
	
func update_words_typed(words_typed: int):
	words_typed_label.text = "# Words Typed: " + str(words_typed)
	
func update_ttk(ttk: float):
	ttk_label.text = "TTK: %.2f" % ttk

func update_accuracy(accuracy: float):
	accuracy_label.text = "Accuracy: %.2f %%" % accuracy

func update_health(health: int, total_health: int):
	health_label.text = str(health) + "/" + str(total_health)
	var health_bar_size_x = original_health_bar_width * health / float(total_health)
	health_bar_container.custom_minimum_size = Vector2(
		health_bar_size_x, health_bar_container.custom_minimum_size.y)

func update_level_time(time_elapsed: float, level_time: float):
	level_time_label.text = "Level Time: %.2f / " % time_elapsed + str(int(level_time))

func clear_stats() -> void:
	wpm_label.text = "WPM: "
	words_typed_label.text = "# Words Typed: "
	ttk_label.text = "TTK: "
	accuracy_label.text = "Accuracy: "
	level_time_label.text = "Level Time: "

func hide_stats() -> void:
	stats_margin_container.visible = false
	timer_margin_container.visible = false
	
func show_stats() -> void:
	stats_margin_container.visible = true
	timer_margin_container.visible = true

func disable_damage_vignette() -> void:
	damage_vignette.is_disabled = true
