extends ItemMenuDialogue

const PHONE_NUMBER_BUTTON: PackedScene = preload("res://src/world/levels/02_reality_tv/menus/phone/phone_number_button.tscn")

@export var pizza_number: String = "555-7383"


func _ready() -> void:
	super()
	%CallButton.pressed.connect(_on_call_button_pressed)
	%ClearButton.pressed.connect(_on_clear_button_pressed)

	for i: int in range(12):
		var new_button: PhoneNumberButton = PHONE_NUMBER_BUTTON.instantiate()
		new_button.index = i
		new_button.pressed.connect(_on_phone_number_button_pressed)
		%PhoneNumberButtons.add_child(new_button)


func _on_phone_number_button_pressed(value: String) -> void:
	if %PhoneNumberLabel.text.length() < 8:
		%PhoneNumberLabel.text += value

	if %PhoneNumberLabel.text.length() == 3:
		%PhoneNumberLabel.text += "-"


func _on_call_button_pressed() -> void:
	resume_game()

	if %PhoneNumberLabel.text == pizza_number:
		start_dialogue("success")
	else:
		start_dialogue("failure")


func _on_clear_button_pressed() -> void:
	%PhoneNumberLabel.text = ""
