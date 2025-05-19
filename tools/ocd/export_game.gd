@tool
extends Node

## Path to store build outputs.
const BUILDS_FOLDER: String = "res://builds"
## Subdirectories to create in builds folder.
const BUILD_SUBDIRS: Array[String] = ["web"]
## Web pages to copy to build output.
const WEB_PAGES: Array[String] = ["about.html", "legal.html"]
var VERSION_HEX: String = str(Engine.get_version_info().hex)

## Stores command output for debugging.
var _file_sizes: Dictionary = {}


func run(should_deploy_to_firebase: bool) -> void:
	_prepare_build_directory()
	_ensure_export_presets()
	_create_web_build()
	if should_deploy_to_firebase:
		_deploy_to_firebase()
	
	print_rich("[color=green][b]Deployment complete![/b][/color]")


## Prepares clean build directory structure.
func _prepare_build_directory() -> void:
	if DirAccess.dir_exists_absolute(BUILDS_FOLDER):
		print("Deleting builds folder.")
		check_ok(
			OS.move_to_trash(ProjectSettings.globalize_path(BUILDS_FOLDER)),
			"Could not delete builds folder."
		)
	
	print("Rebuilding builds folder.")
	check_ok(
		DirAccess.make_dir_absolute(BUILDS_FOLDER),
		"Could not make builds directory."
	)
	
	# Create .gdignore to prevent build files from being imported
	FileAccess.open(BUILDS_FOLDER + "/.gdignore", FileAccess.WRITE)
	
	# Create all required subdirectories
	for subdir in BUILD_SUBDIRS:
		check_ok(
			DirAccess.make_dir_absolute(BUILDS_FOLDER + "/" + subdir),
			"Could not make " + subdir + " directory."
		)


## Ensures export presets exist, creates from default if needed.
func _ensure_export_presets() -> void:
	print("Checking existence of export presets.")
	if not FileAccess.file_exists("res://export_presets.cfg"):
		print("Creating export preset.")
		check_ok(
			DirAccess.copy_absolute(
				"res://addons/ocd/default_export_presets.cfg",
				"res://export_presets.cfg"
			),
			"Could not create export presets."
		)


## Creates the web build with cache busting.
func _create_web_build() -> void:
	var global_builds_folder: String = ProjectSettings.globalize_path(BUILDS_FOLDER)
	var web_dir: String = global_builds_folder + "/web/"
	
	_export_web_build(web_dir)
	_setup_build_files(web_dir)
	_update_godot_config(web_dir)
	_copy_web_pages(global_builds_folder)


## Exports the web build using Godot's export system
func _export_web_build(web_dir: String) -> void:
	print("Creating web build...")
	var versioned_filename: String = "index-%s.html" % VERSION_HEX
	
	var base_args: Array = [
		"--headless",
		"--path",
		ProjectSettings.globalize_path("res://"),
		"--export-release",
		"web",
		web_dir + versioned_filename
	]
	
	check_ok(
		OS.execute("godot", base_args),
		"Failed to export web build."
	)
	
	# Rename the exported file to index.html
	check_ok(
		OS.execute("mv", [
			web_dir + versioned_filename,
			web_dir + "index.html"
		]),
		"Failed to rename web build file."
	)


## Sets up build files with proper naming.
func _setup_build_files(web_dir: String) -> void:
	var wasm_name: String = "index-%s" % VERSION_HEX
	var pck_name: String = "index-%s" % Nanoid.generate(6)
	
	# Rename PCK file for cache busting
	check_ok(
		OS.execute("mv", [
			web_dir + "index-" + VERSION_HEX + ".pck",
			web_dir + pck_name + ".pck"
		]),
		"Failed to rename PCK file."
	)
	
	_file_sizes = {
		"wasm_name": wasm_name,
		"pck_name": pck_name,
		"wasm_size": FileAccess.get_file_as_bytes(web_dir + wasm_name + ".wasm").size(),
		"pck_size": FileAccess.get_file_as_bytes(web_dir + pck_name + ".pck").size()
	}


## Updates the Godot configuration in index.html.
func _update_godot_config(web_dir: String) -> void:
	var godot_config: Dictionary = {
		"args": [
			"--main-pack", _file_sizes.pck_name + ".pck",
		],
		"canvasResizePolicy": 0,
		"ensureCrossOriginIsolationHeaders": true,
		"executable": _file_sizes.wasm_name,
		"mainPack": _file_sizes.pck_name,
		"experimentalVK": false,
		"fileSizes": {
			"%s.pck" % _file_sizes.pck_name: _file_sizes.pck_size,
			"%s.wasm" % _file_sizes.wasm_name: _file_sizes.wasm_size
		},
		"focusCanvas": false,
		"gdextensionLibs": []
	}

	var file: FileAccess = FileAccess.open(web_dir + "index.html", FileAccess.READ_WRITE)
	if file:
		var content: String = file.get_as_text()
		content = content.replace("$CUSTOM_GODOT_CONFIG", JSON.stringify(godot_config))
		file.store_string(content)
		file.close()
	else:
		printerr("Failed to open index.html for updating Godot configuration.")


## Copies web pages to the build directory.
func _copy_web_pages(global_builds_folder: String) -> void:
	print("Copying web pages...")
	for page in WEB_PAGES:
		check_ok(
			DirAccess.copy_absolute(
				"res://web/" + page,
				global_builds_folder + "/web/" + page
			),
			"Could not copy " + page + " page."
		)


## Deploys build to Firebase hosting.
func _deploy_to_firebase() -> void:
	print("Deploying to Firebase.")
	check_ok(
		OS.execute(
			"sh",
			[
				"-c",
				"cd " + ProjectSettings.globalize_path("res://") + " && firebase deploy --only hosting"
			]
		),
		"Failed to deploy to Firebase."
	)


## Checks for errors and prints message if found.
func check_ok(error: int, msg: String) -> void:
	if error:
		printerr(msg)
