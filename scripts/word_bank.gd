extends Node

# TODO
# - store words in a trie, for prediction buff

const MAX_RNG_WORD_ATTEMPTS = 10000
var existing_words := []
var tag_tries: TagTries = preload("res://assets/words/tries_by_tag.tres")

func _ready():
	pass

func get_random_word_from_tag(tag: String) -> String:
	var trie: Trie = tag_tries.tries_by_tag[tag]
	
	# exclude first letters that already exist
	var existing_first_letters := []
	for word in existing_words:
		existing_first_letters.append(word[0])
	var possible_first_letters: Array[String] = trie.get_first_letters()
	for letter in existing_first_letters:
		possible_first_letters.erase(letter)
	if not possible_first_letters or possible_first_letters.size() == 0:
		push_error("Couldn't find a good word to pick...")
		return ""
	# traverse trie to get random letter
	var letter := possible_first_letters[
		Global.rng.randi_range(0, possible_first_letters.size() - 1)]
	var result := letter
	var current: TrieNode = trie.get_root().get_child_trie_node(letter)
	var is_end := current.is_end
	
	while not is_end:
		var next_letter := current.get_random_child_letter()
		result += next_letter
		current = current.get_child_trie_node(next_letter)
		is_end = current.is_end
	
	return result

func _on_enemy_spawner_word_added(enemy: Enemy, word: String):
	existing_words.append(word)

func _on_enemy_word_panel_word_typed(word: String):
	existing_words.erase(word)
	pass
