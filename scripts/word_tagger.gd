@tool
extends EditorScript

const OUTPUT_FILE_PATH = "res://assets/words/words.json"
const TAG_RES_PATH = "res://resources/tags/"

@export var tags: Array[Tag] = []

func _init() -> void:
	var resource_paths: PackedStringArray = ResourceLoader.list_directory(TAG_RES_PATH)
	for path in resource_paths:
		tags.append(ResourceLoader.load(TAG_RES_PATH + path, "Tag"))
	print("Loaded %d tags" % tags.size())

func _run():
	var words_file := FileAccess.open("res://assets/words/wordlist.txt", FileAccess.READ)
	if not words_file:
		printerr("Could not open words list")
		return
	
	var tagged_words = []
	while not words_file.eof_reached():
		var word = words_file.get_line().strip_edges()
		if word == "":
			continue
		var generated_tags = get_tags(word)
		tagged_words.append({
			"word": word,
			"tags": generated_tags
		})
		
		var json_string = JSON.stringify(tagged_words, "\t")  # pretty-print
		var save_file = FileAccess.open(OUTPUT_FILE_PATH, FileAccess.WRITE)
		save_file.store_string(json_string)
		save_file.close()
		
	print("Tagged words saved to: ", OUTPUT_FILE_PATH)
		
func get_tags(word: String) -> Array[String]:
	var generated_tags: Array[String] = []
	
	# generate tags
	for tag in tags:
		if matches(word, tag):
			generated_tags.append(tag.name)
	return generated_tags
	

func matches(word: String, tag: Tag) -> bool:
	# check if there is a tag that exists with that name
	if not tag:
		return false
	
	# check if word has the required keys (e.g. phrases must have a space)
	if not tag.required_keys == "":
		for char in tag.required_keys:
			if char not in word:
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
	if word.length() > tag.max_length:
		return false
		
	if word.length() < tag.min_length:
		return false
	
	return true
