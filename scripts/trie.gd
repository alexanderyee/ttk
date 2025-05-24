class_name Trie
extends Resource

@export var root: TrieNode = TrieNode.new()
@export var num_words := 0

func insert(word: String) -> void:
	var unique = root.insert(word)
	if unique:
		num_words += 1
	
func contains(word: String) -> bool: 
	var current = root
	for char in word:
		if not current.children.has(char):
			return false
		current = current.children[char]
	return current.is_end

func get_first_letters() -> Array[String]:
	return root.get_child_letters()

func get_root() -> TrieNode:
	return root
