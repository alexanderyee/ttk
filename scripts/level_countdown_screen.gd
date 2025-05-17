class_name LevelCountdownScreen
extends CanvasLayer

signal countdown_finished

const COUNTDOWN_TEXT_COLOR = "#000000"

@onready var countdown_label: RichTextLabel = $CountdownLabel
@onready var level_countdown_timer: Timer = $LevelCountdownTimer

func _process(delta: float) -> void:
	if not level_countdown_timer.is_stopped():
		visible = true
		var number_to_display = int(level_countdown_timer.time_left) + 1
		countdown_label.text = "[center][color=%s]" % COUNTDOWN_TEXT_COLOR + \
			str(number_to_display) + "[/color][/center]"
		

func start_countdown(seconds: float) -> void:
	level_countdown_timer.start(seconds)
	

func _on_level_countdown_timer_timeout() -> void:
	level_countdown_timer.stop()
	countdown_finished.emit()
	visible = false
