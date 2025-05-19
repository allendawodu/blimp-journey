class_name CommandCenter
extends Node


func _ready() -> void:
	tree_exiting.connect(_on_tree_exiting)

	_register_console_commands()


func _register_console_commands() -> void:
	# Prevents re-registering commands when reloading the entire world (which causes errors)
	if LimboConsole.has_command("reload"):
		return

	# time [scale]
	LimboConsole.register_command(Engine.set_time_scale, "time", "Set time dilation")

	# reload
	LimboConsole.register_command(SceneLoader.reload_current_scene, "reload", "Reload the entire level")
	LimboConsole.add_alias("restart", "reload")

	# hide
	LimboConsole.register_command(LimboConsole.hide_console, "hide", "Hide the console")

	# save
	LimboConsole.register_command(SaverLoader.save_game, "save", "Save the game")
	
	# load
	LimboConsole.register_command(SaverLoader.load_game, "load", "Load the game")


func _on_tree_exiting() -> void:
	pass
