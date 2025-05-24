@tool
extends EditorScript

func _run():
	var file = FileAccess.open("res://assets/words/words.json", FileAccess.READ)
	var word_data_json = JSON.parse_string(file.get_as_text())
	if word_data_json == null or typeof(word_data_json) != TYPE_ARRAY:
		printerr("Unable to load word data JSON")
		return
	
	var tries_by_tag: Dictionary[String, Trie] = {}
	for row in word_data_json:
		var word = row.get("word", "")
		var tags = row.get("tags", [])
		
		for tag in tags:
			if not tries_by_tag.has(tag):
				tries_by_tag[tag] = Trie.new()
			tries_by_tag[tag].insert(word)
	
	var tag_tries = TagTries.new()
	tag_tries.tries_by_tag = tries_by_tag
	
	var processed_data_path = "res://assets/words/tries_by_tag.tres"
	var err = ResourceSaver.save(tag_tries, processed_data_path)
	
	if err == OK:
		for key in tries_by_tag:
			print("Num words in tag '%s': %d" % [key, tries_by_tag[key].num_words])
		print("Word data saved successfully to ", processed_data_path)
	else:
		printerr("Failed to save word data. Error code: ", err)
