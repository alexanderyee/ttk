class_name EnemyWordPanel
extends PanelContainer

signal word_typed(word: String)
signal word_panel_visibility_changed(visible: bool)

enum KeystrokeResult {TYPO, CORRECT, PHRASE_COMPLETED}

const DEFAULT_PANEL_THEME = preload("res://ui/default_enemy_word_panel_theme.tres")
const ACTIVE_PANEL_THEME = preload("res://ui/active_enemy_word_panel_theme.tres")
const TYPED_LETTER_COLOR = "#ffd60a"

@export var BLINK_INTERVAL = 0.5

var enemy_word_string: String
var is_active: bool
var letter_index := 0 # current letter to be typed
var cursor_blink_timer := 0.0
var cursor_visible = true

@onready var enemy_word: RichTextLabel = $MarginContainer/EnemyWord


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	cursor_blink_timer += delta
	if cursor_blink_timer >= BLINK_INTERVAL:
		cursor_blink_timer = 0.0
		cursor_visible = !cursor_visible
		update_label()
	
func set_word(word: String):
	enemy_word_string = word
	enemy_word.text =  "[center]" + enemy_word_string + "[/center]"
	await get_tree().process_frame
	visible = true
	word_panel_visibility_changed.emit(visible)
	

func get_label() -> RichTextLabel:
	return enemy_word

func get_word() -> String:
	return enemy_word_string

func set_active(active: bool = true) -> void:
	is_active = active
	if active:
		theme = ACTIVE_PANEL_THEME
	else:
		theme = DEFAULT_PANEL_THEME
	

func letter_typed(letter: String) -> KeystrokeResult:
	if is_active:
		if letter == enemy_word_string[letter_index]:
			letter_index += 1
			cursor_visible = true
			cursor_blink_timer = 0.0
			update_label()
			if letter_index >= enemy_word_string.length():
				letter_index = 0
				word_typed.emit(enemy_word_string)
				visible = false
				word_panel_visibility_changed.emit(visible)
				custom_minimum_size.y = 0 # Avoid layout collapse
				return KeystrokeResult.PHRASE_COMPLETED
			return KeystrokeResult.CORRECT
	return KeystrokeResult.TYPO

func update_label():
	# add color to letters typed, underscore cursor to next letter
	if letter_index > 0 and letter_index < enemy_word_string.length():
		var typed_letters = enemy_word_string.substr(0, letter_index)
		var typed_substr = "[center][color=%s]" % TYPED_LETTER_COLOR + typed_letters + "[/color]"
		var untyped_letters = enemy_word_string.substr(letter_index)
		var untyped_substr = "[u]" + untyped_letters[0] + "[/u]" if cursor_visible else untyped_letters[0]
		if untyped_letters.length() > 1:
			untyped_substr += untyped_letters.substr(1)
		untyped_substr += "[/center]"
		enemy_word.text = typed_substr + untyped_substr
