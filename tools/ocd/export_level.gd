@tool
extends Node
# Pack levels into a zip file for the game to download on-demand.

const LEVELS_DIR: String = "res://src/world/levels/"
const BUILDS_DIR: String = "res://builds/"
const EXPORT_PRESET: String = "res://export_presets.cfg"

var level_dir_name: String
var level_code: String


func run(level_path: String) -> void:
	if level_path.is_empty():
		printerr("Level path is empty.")
		return
	
	level_dir_name = level_path.split("/", false)[-1]
	level_code = level_dir_name.left(2)

	_run()


func _run() -> void:
	if not update_export_preset(true):
		return
		
	if not export_level():
		return
		
	if not unzip_level():
		return
		
	if not recreate_directory_structure():
		return
		
	if not copy_level_files():
		return
		
	if not update_export_preset(false):
		return
		
	if not zip_final_level():
		return
		
	if not remove_temp_files():
		return
	
	print_rich("[color=green][b]Level export complete![/b][/color]")


# Edit the export preset
func update_export_preset(add_filter: bool) -> bool:
	var file: FileAccess = FileAccess.open(EXPORT_PRESET, FileAccess.READ_WRITE)

	if file:
		var content: String = file.get_as_text()
		var include_filter: String = LEVELS_DIR + level_dir_name + "/*"
		
		if add_filter:
			content = content.replace("$INCLUDE_FILTER", include_filter)
		else:
			content = content.replace(include_filter, "$INCLUDE_FILTER")

		if file.store_string(content) == false:
			printerr("Failed to update export preset.")
			return false
	else:
		printerr("Failed to open export preset.")
		return false
	
	file.close()
	return true


# Export the level
func export_level() -> bool:
	var export_args: Array[String] = [
		"--headless",
		"--path",
		ProjectSettings.globalize_path("res://"),
		"--export-pack",
		"level",
		ProjectSettings.globalize_path(BUILDS_DIR + level_code + "_temp.zip"),
	]

	if OS.execute("godot", export_args) != OK:
		printerr("Failed to export level.")
		return false
	
	return true


# Unzip the level
func unzip_level() -> bool:
	var args: Array[String] = [
		"-o",
		ProjectSettings.globalize_path(BUILDS_DIR + level_code + "_temp.zip"),
		"-d",
		ProjectSettings.globalize_path(BUILDS_DIR + level_code + "_temp"),
	]

	# Throws an error even if the command is ultimately successful
	OS.execute("unzip", args)
	
	return true


# Remove extra content from extracted level
func recreate_directory_structure() -> bool:
	var dir: DirAccess = DirAccess.open(BUILDS_DIR)

	if not dir:
		printerr("Failed to open builds directory.")
		return false
	
	if dir.make_dir_recursive(level_code + "/src/world/levels") != OK:
		printerr("Failed to recreate directory structure.")
		return false

	if dir.change_dir(level_code) != OK:
		printerr("Failed to change directory.")
		return false
		
	return true


func copy_level_files() -> bool:
	var mv_args_1: Array[String] = [
		"-f",  # Force move without prompting
		ProjectSettings.globalize_path(BUILDS_DIR + level_code + "_temp/src/world/levels/" + level_dir_name),
		ProjectSettings.globalize_path(BUILDS_DIR + level_code + "/src/world/levels/" + level_dir_name),
	]

	if OS.execute("mv", mv_args_1) != OK:
		printerr("Failed to move level files.")
		return false
	
	var mv_args_2: Array[String] = [
		"-f",  # Force move without prompting
		ProjectSettings.globalize_path(BUILDS_DIR + level_code + "_temp/.godot"),
		ProjectSettings.globalize_path(BUILDS_DIR + level_code + "/.godot"),
	]

	if OS.execute("mv", mv_args_2) != OK:
		printerr("Failed to move .godot directory.")
		return false
		
	return true


# Use shell command to navigate to the build directory first
func zip_final_level() -> bool:
	var shell_args: Array[String] = [
		"-c",
		"cd " + ProjectSettings.globalize_path(BUILDS_DIR + level_code) + " && " +
		"zip -r ../" + level_code + ".zip ."
	]
	
	# Zipping throws an error even if the command is ultimately successful
	if OS.execute("sh", shell_args) != OK:
		printerr("Issue zipping level.")
		
	return true


# Remove the temporary directories
func remove_temp_files() -> bool:
	var rm_args_1: Array[String] = [
		"-rf",
		ProjectSettings.globalize_path(BUILDS_DIR + level_code + "_temp"),
	]

	if OS.execute("rm", rm_args_1) != OK:
		printerr("Failed to remove temporary level directory.")
		return false
	
	var rm_args_2: Array[String] = [
		"-rf",
		ProjectSettings.globalize_path(BUILDS_DIR + level_code),
	]

	if OS.execute("rm", rm_args_2) != OK:
		printerr("Failed to unzipped level directory..")
		return false
	
	var rm_args_3: Array[String] = [
		"-f",
		ProjectSettings.globalize_path(BUILDS_DIR + level_code + "_temp.zip"),
	]

	if OS.execute("rm", rm_args_3) != OK:
		printerr("Failed to remove temporary zip file.")
		return false
		
	return true


## Checks for errors and prints message if found.
func check_ok(error: int, msg: String) -> void:
	if error:
		printerr(msg)
