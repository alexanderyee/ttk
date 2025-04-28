class_name UI
extends CanvasLayer

@onready var wpm_label: RichTextLabel = $"MarginContainer/VBoxContainer/WPM Label"
@onready var words_typed_label: RichTextLabel = $"MarginContainer/VBoxContainer/WordsTyped Label"
@onready var ttk_label: RichTextLabel = $"MarginContainer/VBoxContainer/TTK Label"
@onready var accuracy_label: RichTextLabel = $"MarginContainer/VBoxContainer/Accuracy Label"

func update_wpm(wpm: int):
	wpm_label.text = "WPM: " + str(wpm)
	
func update_words_typed(words_typed: int):
	words_typed_label.text = "# Words Typed: " + str(words_typed)
	
func update_ttk(ttk: float):
	ttk_label.text = "TTK: %.2f" % ttk

func update_accuracy(accuracy: float):
	accuracy_label.text = "Accuracy: %.2f %%" % accuracy
