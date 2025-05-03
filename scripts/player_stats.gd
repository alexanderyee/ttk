extends Node

var total_words_typed := 0
var total_letters_typed := 0
var total_typos := 0
var enemies_defeated := 0
var levels_completed := 0
var total_level_time := 0.0
var total_active_time := 0.0

# stats
func get_wpm() -> float:
	return get_total_words_typed() / (get_total_level_time() / 60.0)

func get_ttk() -> float:
	return total_active_time / enemies_defeated

func get_acc() -> float:
	return (float(total_letters_typed) - total_typos) / total_letters_typed * 100

# setters and getters
func get_total_words_typed() -> int:
	return total_words_typed

func add_total_words_typed(value: int) -> void:
	total_words_typed += value

func get_total_letters_typed() -> int:
	return total_letters_typed

func add_total_letters_typed(value: int) -> void:
	total_letters_typed += value

func get_total_typos() -> int:
	return total_typos

func add_total_typos(value: int) -> void:
	total_typos += value

func get_enemies_defeated() -> int:
	return enemies_defeated

func add_enemies_defeated(value: int) -> void:
	enemies_defeated += value

func get_levels_completed() -> int:
	return levels_completed

func add_levels_completed(value: int) -> void:
	levels_completed += value

func get_total_level_time() -> float:
	return total_level_time

func add_total_level_time(value: float) -> void:
	total_level_time += value

func get_total_active_time() -> float:
	return total_active_time

func add_total_active_time(value: float) -> void:
	total_active_time += value
