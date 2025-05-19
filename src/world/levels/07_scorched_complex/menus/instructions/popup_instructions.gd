extends InstructionsMenu

@export var event_name: String = ""


func _ready() -> void:
	super()
	
	var level: Level = get_tree().get_first_node_in_group("level")
	if level:
		if event_name in level.completed_events:
			queue_free()
			return
		else:
			await level.get_node("%AnimationPlayer").animation_finished

	EventBus.about_to_pause.emit("instructions_menu")
	get_tree().paused = true
	show()


func _on_continue_button_pressed() -> void:
	super()

	SaverLoader.complete_event(event_name)
