class_name UI
extends CanvasLayer

@onready var wpm_label: RichTextLabel = $"VBoxContainer/WPM Label"
@onready var words_typed_label: RichTextLabel = $"VBoxContainer/WordsTyped Label"

func update_wpm(wpm: int):
	wpm_label.text = "WPM: " + str(wpm)
	
func update_words_typed(words_typed: int):
	words_typed_label.text = "# Words Typed: " + str(words_typed)
	
