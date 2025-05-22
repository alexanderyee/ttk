@tool
extends EditorScript

const OUTPUT_FILE_PATH = "res://assets/words/words.json"
const LEFT_HAND_KEYS = "qwertasdfgzxcvb "
const HOME_ROW_KEYS = "asdfghjkl "

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
		var tags = get_tags(word)
		tagged_words.append({
			"word": word,
			"tags": tags
		})
		
		var json_string = JSON.stringify(tagged_words, "\t")  # pretty-print
		var save_file = FileAccess.open(OUTPUT_FILE_PATH, FileAccess.WRITE)
		save_file.store_string(json_string)
		save_file.close()
		
	print("Tagged words saved to: ", OUTPUT_FILE_PATH)
		
func get_tags(word: String) -> Array[String]:
	var tags: Array[String] = []
	
	var only_left = true
	var only_home_row = true
	
	var num_regex = RegEx.new()
	num_regex.compile("\\d+")
	var no_numbers = num_regex.search(word) == null
	var is_phrase = false
	# generate tags for location
	for char in word:
		if char not in LEFT_HAND_KEYS:
			only_left = false
		if char not in HOME_ROW_KEYS:
			only_home_row = false
		if char == ' ':
			is_phrase = true
	
	# generate tags for difficulty
	if word.length() <= 5 and no_numbers:
		tags.append("easy-word")
	elif word.length() <= 8:
		if is_phrase:
			tags.append("easy-phrase")
		else:
			tags.append("medium-word")
	elif word.length() <= 16:
		if is_phrase:
			tags.append("medium-phrase")
		else:
			tags.append("hard-word")
	else:
		if is_phrase:
			tags.append("hard-phrase")
		else:
			tags.append("very-hard-word")
	return tags
