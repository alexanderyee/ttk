class_name PlayerDeathScreen
extends CanvasLayer

@onready var wpm_stat: RichTextLabel = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HSplitContainer/WPMStat
@onready var words_typed_stat: RichTextLabel = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HSplitContainer2/WordsTypedStat
@onready var enemies_killed_stat: RichTextLabel = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HSplitContainer3/EnemiesKilledStat
@onready var ttk_stat: RichTextLabel = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HSplitContainer4/TTKStat
@onready var acc_stat: RichTextLabel = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HSplitContainer5/AccStat
@onready var lvls_stat: RichTextLabel = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HSplitContainer6/LvlsStat

func update_stat_labels():
	wpm_stat.text = "%.2f" % PlayerStats.get_total_wpm()
	words_typed_stat.text = str(PlayerStats.get_total_words_typed())
	enemies_killed_stat.text = str(PlayerStats.get_total_words_typed())
	ttk_stat.text = "%.2f" % PlayerStats.get_total_ttk()
	acc_stat.text = "%.2f" % PlayerStats.get_total_acc()
	lvls_stat.text = str(PlayerStats.get_current_level() - 1)


func _on_new_run_button_pressed() -> void:
	# reset stats
	
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	PlayerStats.reset()
