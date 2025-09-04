class_name LevelCountdownScreen
extends CanvasLayer

signal countdown_finished


@onready var countdown_label: RichTextLabel = $CountdownLabel
@onready var level_countdown_timer: Timer = $LevelCountdownTimer
@onready var boss_tip_label: RichTextLabel = $BossTipLabel

func _process(_delta: float) -> void:
	if not level_countdown_timer.is_stopped():
		visible = true
		var number_to_display = int(level_countdown_timer.time_left) + 1
		countdown_label.text = "[center]" + \
			"Ready? " + str(number_to_display) + "[/center]"

		if PlayerStats.get_current_level() == 5:
			boss_tip_label.visible = true
		else:
			boss_tip_label.visible = false
		

func start_countdown(seconds: float) -> void:
	level_countdown_timer.start(seconds)
	

func _on_level_countdown_timer_timeout() -> void:
	level_countdown_timer.stop()
	countdown_finished.emit()
	visible = false
