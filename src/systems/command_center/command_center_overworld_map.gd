class_name CommandCenterOverworldMap
extends CommandCenter


func _ready() -> void:
	super()


func _register_console_commands() -> void:
	super()

	# Prevents re-registering commands when reloading the entire world (which causes errors)
	if LimboConsole.has_command("clearclouds"):
		return

	# clearclouds [region]
	LimboConsole.register_command(_clear_clouds, "clearclouds", "Clears a specified region of clouds")
	LimboConsole.add_argument_autocomplete_source("clearclouds", 1, func(): return %CloudSpawners.get_children().map(func(x): return x.region))

	# reset [level_code]
	LimboConsole.register_command(SaverLoader.reset_level, "reset", "Reset the save file for the specified level")


func _clear_clouds(region: int) -> void:
	for cloud_spawner: CloudSpawner in %CloudSpawners.get_children():
		if cloud_spawner.region == region:
			cloud_spawner.clear_clouds()
			return
	
	printerr("Nothing happened... Check if the region is correct.")


func _on_tree_exiting() -> void:
	LimboConsole.unregister_command("clearclouds")
	LimboConsole.unregister_command("reset")
