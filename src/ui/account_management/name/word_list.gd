class_name WordList
extends Resource

signal word_changed

@export var word_list: Array[String]

var current_index: int = 0


func any() -> String:
	current_index = randi_range(0, word_list.size() - 1)
	word_changed.emit()
	return word_list[current_index]


func next() -> String:
	current_index = wrapi(current_index + 1, 0, word_list.size())
	word_changed.emit()
	return word_list[current_index]


func previous() -> String:
	current_index = wrapi(current_index - 1, 0, word_list.size())
	word_changed.emit()
	return word_list[current_index]


func get_word(index: int = -1) -> String:
	return word_list[current_index] if index == -1 else word_list[index]


func set_word(word: String, should_add_if_not_found: bool = true) -> void:
	var index: int = word_list.find(word)

	if index == -1 and should_add_if_not_found:
		# Custom name granted by the developers
		word_list.append(word)
		current_index = word_list.size() - 1
	elif index == -1:
		printerr("[WordList] Word not found: ", word, ". Aborting...")
		return
	else:
		current_index = index
		
	word_changed.emit()
