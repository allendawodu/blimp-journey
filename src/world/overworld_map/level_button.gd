class_name LevelButton
extends Area2D

## Maximum outline width for hover effect
const OUTLINE_WIDTH_MAX: float = 5
## Minimum outline width for hover effect
const OUTLINE_WIDTH_MIN: float = 3

## Prevent multiple clicks or level switching while processing
static var is_processing_level: bool

## Path to the scene file that will be loaded
@export_file("*.tscn") var level_path: String
## Unique identifier for the level to download from Firebase
@export var level_code: String
## Region ID. Setting to -1 means it's already active
@export var region: int = -1

## Firebase storage reference
var _ref: StorageReference
## Path to store level metadata locally
var _level_metadata_path: String
## Path to store level zip file locally
var _level_zip_path: String


func _ready() -> void:
	EventBus.clouds_cleared.connect(_on_clouds_cleared)
	
	# Hide and disable interaction if the level is not yet active
	if region != -1:
		input_pickable = false
		hide()
	
	# Initialize paths
	_level_metadata_path = "user://levels/%s.metadata" % level_code
	_level_zip_path = "user://levels/%s.zip" % level_code


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if not Maid.is_left_click(event) or is_processing_level:
		return
	
	is_processing_level = true

	_ref = Firebase.Storage.ref("levels/%s.zip" % level_code)
	
	# Check if we need to download or update the level
	if _is_level_cached():
		%MessageLabel.text = "Checking level..."
		var is_up_to_date = await _check_level_is_up_to_date()
		if is_up_to_date:
			load_level()
		else:
			await _update_level()
			load_level()
	else:
		%MessageLabel.text = "Downloading level..."
		await _download_level()
		load_level()
	
	%MessageLabel.text = "Loading failed."

	is_processing_level = false


# Checks if the level files exist locally
func _is_level_cached() -> bool:
	return FileAccess.file_exists(_level_zip_path) and FileAccess.file_exists(_level_metadata_path)


# Checks if the cached level matches the server version
func _check_level_is_up_to_date() -> bool:
	var file: FileAccess = FileAccess.open(_level_metadata_path, FileAccess.READ)
	if not file:
		printerr("[LevelButton] Failed to open level metadata file.")
		return false
	
	var cached_hash: String = file.get_as_text().strip_escapes()
	file.close()
	
	var metadata = await _ref.get_metadata()
	if metadata is not Dictionary:
		printerr("[LevelButton] Failed to get level metadata from server.")
		return false
	
	return cached_hash == metadata.md5Hash


# Updates an outdated level by deleting and downloading again
func _update_level() -> void:
	delete_level()
	await _download_level()


# Downloads the level from Firebase Storage
func _download_level() -> void:
	print("[LevelButton] Downloading level...")
	
	# Ensure the levels directory exists
	if not DirAccess.dir_exists_absolute("user://levels/"):
		DirAccess.make_dir_absolute("user://levels/")
	
	# Download level data
	var data = await _ref.get_data()
	if data is not PackedByteArray:
		printerr("[LevelButton] Failed to download level data.")
		return
	
	# Store the level zip file
	var file = FileAccess.open(_level_zip_path, FileAccess.WRITE)
	if not file:
		printerr("[LevelButton] Failed to open level file for writing.")
		return
	file.store_buffer(data)
	file.close()
	
	# Download and store metadata
	var metadata = await _ref.get_metadata()
	if metadata is not Dictionary:
		printerr("[LevelButton] Failed to get level metadata.")
		return
	
	file = FileAccess.open(_level_metadata_path, FileAccess.WRITE)
	if not file:
		printerr("[LevelButton] Failed to open metadata file for writing.")
		return
	file.store_string(metadata.md5Hash)
	file.close()
	
	print("[LevelButton] Level downloaded successfully.")


# Loads the level from the downloaded resource pack
func load_level() -> void:
	print("[LevelButton] Loading level...")
	
	if ProjectSettings.load_resource_pack(_level_zip_path):
		print("[LevelButton] Level loaded successfully.")
		get_tree().change_scene_to_file(level_path)
	else:
		printerr("[LevelButton] Failed to load level resource pack.")


# Deletes the level files
func delete_level() -> void:
	print("[LevelButton] Deleting level files...")
	
	if FileAccess.file_exists(_level_zip_path):
		DirAccess.remove_absolute(_level_zip_path)
	
	if FileAccess.file_exists(_level_metadata_path):
		DirAccess.remove_absolute(_level_metadata_path)


func _mouse_enter() -> void:
	$Sprite2D.material.set_shader_parameter("minLineWidth", OUTLINE_WIDTH_MIN)
	$Sprite2D.material.set_shader_parameter("maxLineWidth", OUTLINE_WIDTH_MAX)
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _mouse_exit() -> void:
	$Sprite2D.material.set_shader_parameter("minLineWidth", 0)
	$Sprite2D.material.set_shader_parameter("maxLineWidth", 0)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


## Becomes active when the clouds disappear for this region
func _on_clouds_cleared(p_region: int) -> void:
	if p_region == region:
		input_pickable = true
		show()
		region = -1
