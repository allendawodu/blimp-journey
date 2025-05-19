extends Button

@export var characters: Array[String]

var character_index: int = 0


func _ready() -> void:
	pressed.connect(_on_pressed)

	characters.shuffle()

	set_button_text(characters[character_index])


func set_button_text(character: String) -> void:
	if character.begins_with("0x"):
		text = char(character.hex_to_int())
	else:
		text = character


func _on_pressed() -> void:
	character_index = (character_index + 1) % characters.size()
	set_button_text(characters[character_index])
