extends InstructionsMenu

static var is_game_over_screen_displayed: bool

@onready var _level: Level = get_tree().get_first_node_in_group("level")


func _ready() -> void:
	super()
	is_game_over_screen_displayed = false


func _on_dialogic_signal_event(event: Variant) -> void:
	if not is_game_over_screen_displayed and event == dialogic_signal_to_show:
		# Wait for the timeline to end before showing the menu
		if Dialogic.current_timeline:
			await Dialogic.timeline_ended
		
		await get_tree().process_frame

		EventBus.about_to_pause.emit("instructions_menu")
		get_tree().paused = true
		show()

		is_game_over_screen_displayed = true


func _on_continue_button_pressed() -> void:
	super()
	Dialogic.VAR.set_variable("07.tank_level", 100)
	_level.reload_current_scene()
