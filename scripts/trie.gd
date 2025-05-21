class_name Trie
extends Resource

@export var root: TrieNode = TrieNode.new()

func insert(word: String) -> void:
	root.insert(word)
	
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
