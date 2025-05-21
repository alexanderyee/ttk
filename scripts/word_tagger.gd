@tool
extends EditorScript

const OUTPUT_FILE_PATH = "res://assets/words/words.json"
const LEFT_HAND_KEYS = "qwertasdfgzxcvb"
const HOME_ROW_KEYS = "asdfghjkl"

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
	var tags = []
	
	var only_left = true
	var only_home_row = true
	
	var num_regex = RegEx.new()
	num_regex.compile("\\d+")
	var no_numbers_result = num_regex.search(word)
	var no_numbers = false
	# generate tags for location
	for char in word:
		if char not in LEFT_HAND_KEYS:
			only_left = false
		if char not in HOME_ROW_KEYS:
			only_home_row = false
	
	# generate tags for difficulty
	var is_phrase = false
	if word.length() <= 4 and no_numbers:
		tags.append("easy-word")
	elif word.length() <= 6:
		tags.append("medium-word")
	else:
		tags.append("hard-word")
	return tags
