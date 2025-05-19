@tool
extends Node

var global_svg_file_path: String
var svg_file_path: String
var style_name_suffix: String

const OUTPUT_DIR_TEMPLATE: String = "res://src/character/styles/%s/"


func run(path: String) -> void:
	if path.is_empty():
		printerr("File path is empty.")
		return
	
	global_svg_file_path = path
	style_name_suffix = path.get_file().get_basename().to_snake_case()

	_run()


func _run() -> void:
	var output_dir: String = OUTPUT_DIR_TEMPLATE % style_name_suffix
	
	if not _create_directory(output_dir):
		return
	
	svg_file_path = output_dir + style_name_suffix + ".svg"
	if not _copy_svg_file():
		return

	var ids: Array[String] = [
		"ref",
		"hair_back",
		"hair_front",
		"eyebrow_r",
		"eyebrow_l",
		"eyewear",
		"mouth",
		"face_marks",
		"facial_hair",
		"shirt",
		"overshirt",
		"pack",
		"wrist_r",
		"wrist_l",
		"held_item_r",
		"held_item_l",
		"pants",
		"overpants",
		"sock_r",
		"sock_l",
		"shoe_r",
		"shoe_l",
		# "head",
		# "eye_r",
		# "eye_l",
		# "eyelid_r",
		# "eyelid_l",
		# "pupil_r",
		# "pupil_l",
		# "torso",
		# "hand_r",
		# "hand_l",
		# "leg_r",
		# "leg_l",
	]

	var metadata: Dictionary = _export_metadata(ids)
	if metadata.is_empty():
		return
	
	var export_ids: Array[String] = _filter_export_ids(ids, metadata)
	
	if not _export_pngs(export_ids, output_dir):
		return
	
	if not _delete_svg_file():
		return
	
	await _refresh_filesystem()
	
	if not _create_style_parts(export_ids, output_dir, metadata):
		return
	
	await _refresh_filesystem()
	
	if not _create_style(export_ids, output_dir):
		return
	
	await _refresh_filesystem()
	
	print_rich("[color=green][b]Import complete![/b][/color]")


func _create_directory(dir_path: String) -> bool:
	if not DirAccess.dir_exists_absolute(dir_path):
		if DirAccess.make_dir_absolute(dir_path) != OK:
			printerr("Failed to create directory: %s" % dir_path)
			return false
	return true


func _copy_svg_file() -> bool:
	if DirAccess.copy_absolute(global_svg_file_path, svg_file_path) != OK:
		printerr("Failed to copy file: %s" % global_svg_file_path)
		return false
	return true


func _export_metadata(ids: Array[String]) -> Dictionary:
	var output: Array
	if !check_ok(
		OS.execute(
			"inkscape",
			[
				"--query-id=%s" % ",".join(ids),
				"--query-x",
				"--query-y",
				"--query-width",
				"--query-height",
				ProjectSettings.globalize_path(svg_file_path)
			],
			output,
			true
		),
		"Failed to export metadata from %s." % ProjectSettings.globalize_path(svg_file_path)
	):
		return {}
	
	# Check for IDs that are not in the SVG
	const ID_NOT_FOUND_TEMPLATE: String = "select_by_id: Did not find object with id: %s\n"
	for i: int in range(ids.size() - 1, -1, -1):
		var id_not_found: String = ID_NOT_FOUND_TEMPLATE % ids[i]
		if id_not_found in output[0]:
			prints("Couldn't find ID:", ids[i])
			ids.remove_at(i)
			output[0] = output[0].replace(id_not_found, "")

	# Parse the metadata
	var data: Array[Array] = []
	var rows: Array = output[0].split("\n", false)
	for row in rows:
		var columns: Array = row.split(",")
		var float_columns: Array = []
		for value in columns:
			float_columns.append(float(value))
		data.append(float_columns)

	var metadata: Dictionary = {}
	for i: int in range(ids.size()):
		if is_zero_approx(data[2][i]) or is_zero_approx(data[3][i]):
			continue

		metadata[ids[i]] = {
			position = Vector2(data[0][i], data[1][i]),
			width = data[2][i],
			height = data[3][i],
		}
	
	return metadata


func _filter_export_ids(ids: Array[String], metadata: Dictionary) -> Array[String]:
	var export_ids: Array[String] = []
	for id in ids:
		if id in metadata and id != "ref":
			export_ids.append(id)
	return export_ids


func _export_pngs(ids: Array[String], output_dir: String) -> bool:
	var success: bool = true
	for id: String in ids:
		var result: int = OS.execute(
			"inkscape",
			[
				"--export-id=%s" % id,
				"--export-id-only",
				"--export-type=png",
				"--export-area-snap",
				"--export-filename=%s/%s_%s.png" % [
					ProjectSettings.globalize_path(output_dir),
					id,
					style_name_suffix
				],
				ProjectSettings.globalize_path(svg_file_path),
			]
		)
		
		if !check_ok(
			result,
			"Failed to export %s from %s." % [id, ProjectSettings.globalize_path(svg_file_path)]
		):
			success = false
	
	return success


func _delete_svg_file() -> bool:
	if DirAccess.remove_absolute(svg_file_path) != OK:
		printerr("Failed to delete file: %s" % svg_file_path)
		return false
	return true


func _refresh_filesystem() -> void:
	EditorInterface.get_resource_filesystem().scan()
	await get_tree().process_frame


func _create_style_parts(ids: Array[String], output_dir: String, metadata: Dictionary) -> bool:
	var character: Character = preload("res://src/character/common/character.tscn").instantiate()
	
	for id: String in ids:
		var image_path: String = "%s%s_%s.png" % [output_dir, id, style_name_suffix]
		if not _create_style_part(id, image_path, metadata, character):
			return false
	
	character.queue_free()
	return true


func _create_style_part(id: String, image_path: String, metadata: Dictionary, character: Character) -> bool:
	var image: Image = Image.load_from_file(image_path)
	image.fix_alpha_edges()
	var texture: Texture2D = ImageTexture.create_from_image(image)

	var style_part: StylePart = StylePart.new()
	style_part.name = id.to_pascal_case()
	style_part.style_name = "%s_%s" % [id, style_name_suffix]
	style_part.part = CharacterParts.string_to_character_part(id)

	var sprite_2d: Sprite2D = Sprite2D.new()
	sprite_2d.texture = texture
	
	# Calculate position
	sprite_2d.position = _calculate_sprite_position(id, metadata, character)

	style_part.add_child(sprite_2d)
	sprite_2d.owner = style_part

	var scene: PackedScene = PackedScene.new()
	if scene.pack(style_part) != OK:
		printerr("Failed to pack scene")
		return false

	var scene_path: String = image_path.replace(".png", ".tscn")
	if ResourceSaver.save(scene, scene_path, ResourceSaver.SaverFlags.FLAG_CHANGE_PATH) != OK:
		printerr("Failed to save scene: %s" % scene_path)
		return false
	
	return true


func _calculate_sprite_position(id: String, metadata: Dictionary, character: Character) -> Vector2:
	var position: Vector2 = metadata[id].position \
			- metadata.ref.position \
			+ Vector2(ceilf(metadata[id].width) / 2, ceilf(metadata[id].height) / 2)
	
	match id:
		"wrist_l", "held_item_l":
			position -= character.get_node("%HandL").position
		"pack", "pants", "overpants", "shirt", "overshirt":
			position -= character.get_node("%Torso").position
		"hair_back", "mouth", "hair_front", "eyebrow_r", "eyebrow_l", "face_marks", "facial_hair", "eyewear", "eye_r", "eye_l", "eyelid_r", "eyelid_l", "pupil_r", "pupil_l":
			position -= character.get_node("%Head").position
		"sock_l", "shoe_l":
			position -= character.get_node("%LegL").position
		"sock_r", "shoe_r":
			position -= character.get_node("%LegR").position
		"held_item_r", "wrist_r":
			position -= character.get_node("%HandR").position
	
	return position


func _create_style(ids: Array[String], output_dir: String) -> bool:
	var dict: Dictionary[String, PackedScene] = {}
	
	for id: String in ids:
		var part_path: String = "%s%s_%s.tscn" % [output_dir, id, style_name_suffix]
		var scene: PackedScene = load(part_path)
		dict[id] = scene
	
	var style: Style = Style.create_style_from_dictionary(dict)

	var path: String = "%s%s.tres" % [output_dir, style_name_suffix]
	if ResourceSaver.save(style, path, ResourceSaver.SaverFlags.FLAG_CHANGE_PATH) != OK:
		printerr("Failed to save style: %s" % path)
		return false
	
	return true


## Checks for errors and prints message if found.
## Returns true if no error, false otherwise.
func check_ok(error: int, msg: String) -> bool:
	if error:
		printerr(msg)
		return false
	return true
