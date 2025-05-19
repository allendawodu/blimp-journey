extends InstructionsMenu

@export var timer: Timer


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal_event)

	%ContinueButton.pressed.connect(_on_continue_button_pressed)

	# DEBUG
	# await get_tree().create_timer(0.5).timeout
	# _on_dialogic_signal_event("start_combat")


func _on_continue_button_pressed() -> void:
	EventBus.about_to_resume.emit("instructions_menu")
	get_tree().paused = false
	hide()
	timer.start()


func _on_dialogic_signal_event(event: Variant) -> void:
	# Wait for the timeline to end so that the mouse can be visible
	# The proper way to do this would be to wait for the signal
	await get_tree().create_timer(0.1).timeout
	
	if event == "start_combat":
		show()
		EventBus.about_to_pause.emit("instructions_menu")
		get_tree().paused = true
