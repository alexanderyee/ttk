class_name UI
extends CanvasLayer

var original_health_bar_width : float
@onready var wpm_label: RichTextLabel = $"StatsMarginContainer/VBoxContainer/WPM Label"
@onready var words_typed_label: RichTextLabel = $"StatsMarginContainer/VBoxContainer/WordsTyped Label"
@onready var ttk_label: RichTextLabel = $"StatsMarginContainer/VBoxContainer/TTK Label"
@onready var accuracy_label: RichTextLabel = $"StatsMarginContainer/VBoxContainer/Accuracy Label"
@onready var health_label: RichTextLabel = $HealthLabelContainer/HealthLabel
@onready var health_bar_container: MarginContainer = $HealthBarContainer

func _ready() -> void:
	original_health_bar_width = health_bar_container.custom_minimum_size.x
	
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
