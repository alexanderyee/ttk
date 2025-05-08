extends Node

var level_stats: Dictionary[int, TypingStats] = {}
var current_level := 1
var total_stats : TypingStats

func _ready() -> void:
	level_stats[current_level] = TypingStats.new()
	total_stats = TypingStats.new()

# getters
func get_level_wpm() -> float:
	return level_stats[current_level].get_wpm()
	
func get_total_wpm() -> float:
	return total_stats.get_wpm()


func get_level_words_typed() -> int:
	return level_stats[current_level].get_num_words_typed()
	
func get_level_letters_typed() -> int:
	return level_stats[current_level].get_letters_typed()

func get_total_words_typed() -> int:
	return total_stats.get_num_words_typed()


func get_level_enemies_killed() -> int:
	return level_stats[current_level].get_enemies_killed()
	
func get_total_enemies_killed() -> int:
	return total_stats.get_enemies_killed()


func get_level_ttk() -> float:
	return level_stats[current_level].get_ttk()
	
func get_total_ttk() -> float:
	return total_stats.get_ttk()


func get_level_acc() -> float:
	return level_stats[current_level].get_acc()
	
func get_total_acc() -> float:
	return total_stats.get_acc()


func get_current_level() -> int:
	return current_level


# setters
func add_words_typed(word: String) -> void:
	level_stats[current_level].add_word_typed(word)
	total_stats.add_word_typed(word)

func add_letters_typed(num_letters: int) -> void:
	level_stats[current_level].add_letters_typed(num_letters)
	total_stats.add_letters_typed(num_letters)


func add_typos(num_typos: int) -> void:
	level_stats[current_level].add_typos(num_typos)
	total_stats.add_typos(num_typos)


func add_enemies_killed(num_enemies_killed: int) -> void:
	level_stats[current_level].add_enemies_killed(num_enemies_killed)
	total_stats.add_enemies_killed(num_enemies_killed)


func add_level_time(level_time: float) -> void:
	level_stats[current_level].add_level_time(level_time)
	total_stats.add_level_time(level_time)


func add_active_time(active_time: float) -> void:
	level_stats[current_level].add_active_time(active_time)
	total_stats.add_active_time(active_time)


func increment_current_level() -> void:
	current_level += 1
	level_stats[current_level] = TypingStats.new()
