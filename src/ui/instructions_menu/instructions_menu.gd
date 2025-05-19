class_name InstructionsMenu
extends Control

## Name of the Dialogic signal event to show the instructions menu.
@export var dialogic_signal_to_show: String


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal_event)
	%ContinueButton.pressed.connect(_on_continue_button_pressed)


func _on_dialogic_signal_event(event: Variant) -> void:
	if event == dialogic_signal_to_show:
		# Wait for the timeline to end before showing the menu
		if Dialogic.current_timeline:
			await Dialogic.timeline_ended
		
		await get_tree().process_frame

		EventBus.about_to_pause.emit("instructions_menu")
		get_tree().paused = true
		show()


func _on_continue_button_pressed() -> void:
	hide()
	EventBus.about_to_resume.emit("instructions_menu")
	get_tree().paused = false
