extends ItemMenu


func _ready() -> void:
	super()

	%TouchpadButton.pressed.connect(_on_touchpad_button_pressed)
	%MouseButton.pressed.connect(_on_mouse_button_pressed)

	# Pause the game
	await get_tree().create_timer(1.1).timeout
	interact()


func _on_touchpad_button_pressed() -> void:
	AppSettings.set_air_control(true)
	resume_game()


func _on_mouse_button_pressed() -> void:
	AppSettings.set_air_control(false)
	resume_game()
