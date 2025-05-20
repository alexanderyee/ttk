class_name TrieNode
extends Resource

@export var children: Dictionary[String, TrieNode] = {}
@export var is_end: bool = false

func insert(word: String):
	var current = self
	for char in word:
		if not current.children.has(char):
			var new_node = TrieNode.new()
			current.children[char] = new_node
		current = current.children[char]
	current.is_end = true
