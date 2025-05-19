@tool
class_name CharacterParts
extends RefCounted
## Define the parts of a character's appearance.

enum Part {
	NONE,
	HEAD,
	HAIR_BACK,
	HAIR_FRONT,
	EYE_R,
	EYE_L,
	PUPIL_R,
	PUPIL_L,
	EYELID_R,
	EYELID_L,
	EYEBROW_R,
	EYEBROW_L,
	EYEWEAR,
	MOUTH,
	FACE_MARKS,
	FACIAL_HAIR,
	TORSO,
	SHIRT,
	OVERSHIRT,
	PACK,
	HAND_R,
	HAND_L,
	WRIST_R,
	WRIST_L,
	HELD_ITEM_R,
	HELD_ITEM_L,
	PANTS,
	OVERPANTS,
	LEG_R,
	LEG_L,
	SOCK_R,
	SOCK_L,
	SHOE_R,
	SHOE_L,
}

const STYLE_PARTS_GROUP: ResourceGroup = preload("res://src/character/common/style/style_parts_group.tres")

static var style_parts: Dictionary[String, StylePart]


static func character_part_to_string(part: Part) -> String:
	return Part.keys()[part].to_snake_case()


static func string_to_character_part(part: String) -> Part:
	var part_enum: int = Part.keys().find(part.to_snake_case().to_upper())

	if part_enum == -1:
		printerr("[CharacterParts] Invalid part name: ", part)
		return Part.NONE
	
	return part_enum as Part


static func get_style_part_from_style_name(style_name: String) -> StylePart:
	if style_parts.is_empty():
		print("[CharacterParts] Style parts dictionary is empty. Populating...")
		populate_style_parts()
	
	return style_parts.get(style_name, null)


static func populate_style_parts() -> void:
	# If this becomes too slow, I can use `load_all_in_background`
	var scenes: Array = STYLE_PARTS_GROUP.load_all()

	for scene: PackedScene in scenes:
		var style_part: StylePart = scene.instantiate() as StylePart

		if style_part == null:
			print("[CharacterParts] Failed to instantiate style part: ", scene)
			continue

		style_parts[style_part.style_name] = style_part
