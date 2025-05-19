@tool
class_name Body
extends Node2D

signal style_part_updated

var _style: Style = Style.new()


func set_style(style: Style) -> void:
	if style == null:
		printerr("[Body] Style can't be null.")
		return
	
	# Reset unused parts
	for part_key: String in _style.get_all_style_attributes().keys():
		var part_value: Variant = style.get(part_key)

		if part_value == null:
			reset_part(CharacterParts.string_to_character_part(part_key))
	
	# Set the new style
	for style_part: StylePart in style.get_all_style_parts_used():
		set_style_part(style_part)
	
	set_skin_color(style.color_skin)

	# Set the colors for all other parts
	for part_key: String in _style.get_all_style_attributes().keys():
		if part_key.begins_with("color_") and part_key != "color_skin":
			var part_color: Color = style.get(part_key)

			if part_color.is_equal_approx(Color.WHITE):
				continue
			
			var part_name: String = part_key.replace("color_", "")
			set_part_color(CharacterParts.string_to_character_part(part_name), part_color)


func set_style_part(style_part: StylePart) -> void:
	if not is_instance_valid(style_part):
		printerr("[Body] StylePart can't be null.")
		return
	
	# Prevent character glitch from the body StyleParts being re-set
	if style_part.style_name in _style.get_all_style_parts_used().map(func(x): return x.style_name):
		return
	
	var property: String = CharacterParts.character_part_to_string(style_part.part)

	_replace_body_part(property, style_part)

	style_part_updated.emit()


func set_skin_color(color: Color) -> void:
	var body_parts: Array[CharacterParts.Part] = [
		CharacterParts.Part.HEAD,
		CharacterParts.Part.EYELID_R,
		CharacterParts.Part.EYELID_L,
		CharacterParts.Part.TORSO,
		CharacterParts.Part.HAND_R,
		CharacterParts.Part.HAND_L,
		CharacterParts.Part.LEG_R,
		CharacterParts.Part.LEG_L,
	]

	_style.set("color_skin", color)

	for body_part: CharacterParts.Part in body_parts:
		set_part_color(body_part, color)


func set_part_color(part: CharacterParts.Part, color: Color) -> void:
	var property: String = CharacterParts.character_part_to_string(part)
	var body_part: Node2D = get_node_or_null("%%%s" % property.to_pascal_case())
	
	if not body_part:
		printerr("[Body] No body part found to color for %%%s" % property.to_pascal_case())
		return
	
	_style.set("color_" + property, color)
	
	if body_part.has_method("set_color"):
		body_part.set_color(color)
	else:
		body_part.self_modulate = color


func reset_part(part: CharacterParts.Part) -> void:
	var property: String = CharacterParts.character_part_to_string(part)
	var old_part: Node2D = get_node_or_null("%%%s" % property.to_pascal_case())

	if not old_part:
		printerr("[Body] No body part found to reset for %%%s" % property.to_pascal_case())
		return

	var new_part: Sprite2D = Sprite2D.new()

	_style.set(property, null)
	
	new_part.name = old_part.name
	new_part.self_modulate = old_part.self_modulate
	new_part.unique_name_in_owner = old_part.unique_name_in_owner
	old_part.replace_by(new_part)
	old_part.queue_free()

	style_part_updated.emit()


## Returns a duplicate of the style.
func get_style() -> Style:
	return _style.duplicate(true)


func override_eye_tracking(target_position: Vector2, should_show_eyelids: bool = false) -> void:
	var pupils: Array[Node] = [get_node_or_null("%PupilR"), get_node_or_null("%PupilL")]
	for pupil: Node in pupils:
		if is_instance_valid(pupil) and pupil is EyeTrackingPupil:
			pupil.set_target_position(target_position)
	
	set_eyelids_visibility(should_show_eyelids)


func reset_eye_tracking() -> void:
	var pupils: Array[Node] = [get_node_or_null("%PupilR"), get_node_or_null("%PupilL")]
	for pupil: Node in pupils:
		if is_instance_valid(pupil) and pupil is EyeTrackingPupil:
			pupil.track_mouse_position()
	
	set_eyelids_visibility(true)


func set_eyelids_visibility(should_show: bool) -> void:
	var eyelids: Array[Node] = [get_node_or_null("%EyelidR"), get_node_or_null("%EyelidL")]
	for eyelid: Node in eyelids:
		if is_instance_valid(eyelid) and eyelid is StylePart:
			eyelid.visible = should_show


# Helper function to replace a body part with a new one and update the style
func _replace_body_part(property: String, new_part: StylePart) -> void:
	var old_part: Node2D = get_node_or_null("%%%s" % property.to_pascal_case())
	
	if not old_part:
		printerr("[Body] No old part found for %%%s" % property.to_pascal_case())
		return
	
	# Repack the StylePart
	var scene: PackedScene = PackedScene.new()
	scene.pack(new_part)
	_style.set(property, scene)
	
	new_part.name = old_part.name
	new_part.set_color(old_part.self_modulate)
	new_part.unique_name_in_owner = old_part.unique_name_in_owner
	old_part.replace_by(new_part)

	# Remove the old part's children as well
	for child: Node in new_part.get_children():
		if child.owner == old_part:
			child.queue_free()
	
	old_part.queue_free()
