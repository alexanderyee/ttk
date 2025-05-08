class_name TypingStats
extends Node


var words_typed := 0
var letters_typed := 0
var typos := 0
var enemies_killed := 0
var level_time := 0.0
var active_time := 0.0


# stats
func get_wpm() -> float:
	return (get_letters_typed() / 5.0) / (get_level_time() / 60.0)

func get_ttk() -> float:
	return active_time / enemies_killed

func get_acc() -> float:
	return (float(letters_typed) - typos) / letters_typed * 100

# setters and getters
func get_num_words_typed() -> int:
	return words_typed

func add_num_words_typed(value: int) -> void:
	words_typed += value

func add_word_typed(word: String) -> void:
	add_num_words_typed(get_num_words(word))

func get_letters_typed() -> int:
	return letters_typed

func add_letters_typed(value: int) -> void:
	letters_typed += value

func get_typos() -> int:
	return typos

func add_typos(value: int) -> void:
	typos += value

func get_enemies_killed() -> int:
	return enemies_killed

func add_enemies_killed(value: int) -> void:
	enemies_killed += value

func get_level_time() -> float:
	return level_time

func add_level_time(value: float) -> void:
	level_time += value

func get_active_time() -> float:
	return active_time

func add_active_time(value: float) -> void:
	active_time += value


# helper functions
func get_num_words(word: String) -> int:
	return word.count(" ") + 1
	
