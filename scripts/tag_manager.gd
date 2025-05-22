class_name TagManager
extends Node

const TAG_NAMES: Array[String] = [
	"left-hand-only",
	"home-row-only",
	"easy-word",
	"easy-phrase",
	"medium-word",
	"medium-phrase",
	"hard-word",
	"hard-phrase",
	"very-hard-word"
]
@export var tags: Array[Tag] = []

func get_tag(name: String) -> Tag:
	for tag in tags:
		if tag.name == name:
			return tag
	return null
	
func matches(word: String, tag_name: String) -> bool:
	var tag = get_tag(tag_name)
	
	# check if there is a tag that exists with that name
	if not tag:
		return false
	
	# check if word has only allowed keys
	if not tag.allowed_keys == "":
		for char in word:
			if char not in tag.allowed_keys:
				return false
				
	# check if word has any forbidden keys
	if not tag.forbidden_keys == "":
		for char in word:
			if char in tag.forbidden_keys:
				return false
				
	# check word length
	if tag.max_length > 0 and word.length() > tag.max_length:
		return false
		
	if word.length() < tag.min_length:
		return false
	
	return true
