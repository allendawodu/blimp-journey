extends CommandCenterLevel


func _register_console_commands() -> void:
	super()

	# hidden
	LimboConsole.register_command(_hidden, "hidden", "Prevent ghosts from seeing the player")

	# refill
	LimboConsole.register_command(_refill, "refill", "Refill the player's water pack")


func _hidden() -> void:
	var scene: Scene = _level.scene

	var ghosts = scene.find_children("*Ghost*", "CharacterBody2D")
	for ghost in ghosts:
		ghost.queue_free()
	
	if not _level.scene_changed.is_connected(_hidden):
		_level.scene_changed.connect(_hidden.unbind(1))


func _refill() -> void:
	Dialogic.VAR.set_variable("07.tank_level", 100)
