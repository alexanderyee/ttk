class_name LevelIntermissionScreen
extends CanvasLayer

signal begin_next_level

@onready var wpm_stat: RichTextLabel = $MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/HSplitContainer/WPMStat
@onready var words_typed_stat: RichTextLabel = $MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/HSplitContainer2/WordsTypedStat
@onready var enemies_killed_stat: RichTextLabel = $MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/HSplitContainer3/EnemiesKilledStat
@onready var ttk_stat: RichTextLabel = $MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/HSplitContainer4/TTKStat
@onready var acc_stat: RichTextLabel = $MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/HSplitContainer5/AccStat

func update_stat_labels():
	wpm_stat.text = "%.2f" % PlayerStats.get_level_wpm()
	words_typed_stat.text = str(PlayerStats.get_level_words_typed())
	enemies_killed_stat.text = str(PlayerStats.get_level_words_typed())
	ttk_stat.text = "%.2f" % PlayerStats.get_level_ttk()
	acc_stat.text = "%.2f" % PlayerStats.get_level_acc()


func _on_next_level_button_pressed() -> void:
	begin_next_level.emit()
