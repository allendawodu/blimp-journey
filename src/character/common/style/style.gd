@tool
class_name Style
extends Resource

const EXPORTED_SCRIPT_VARIABLE_USAGE_FLAGS: int = PROPERTY_USAGE_EDITOR\
		| PROPERTY_USAGE_SCRIPT_VARIABLE\
		| PROPERTY_USAGE_STORAGE

@export var hair_back: PackedScene
@export var hair_front: PackedScene
@export var eyebrow_r: PackedScene
@export var eyebrow_l: PackedScene
@export var eyewear: PackedScene
@export var mouth: PackedScene
@export var face_marks: PackedScene
@export var facial_hair: PackedScene
@export var shirt: PackedScene
@export var overshirt: PackedScene
@export var pack: PackedScene
@export var wrist_r: PackedScene
@export var wrist_l: PackedScene
@export var held_item_r: PackedScene
@export var held_item_l: PackedScene
@export var pants: PackedScene
@export var overpants: PackedScene
@export var sock_r: PackedScene
@export var sock_l: PackedScene
@export var shoe_r: PackedScene
@export var shoe_l: PackedScene

@export_group("Colors", "color_")
@export var color_skin: Color = Color.WHITE
@export var color_head: Color = Color.WHITE
@export var color_eyelid_r: Color = Color.WHITE
@export var color_eyelid_l: Color = Color.WHITE
@export var color_torso: Color = Color.WHITE
@export var color_hand_r: Color = Color.WHITE
@export var color_hand_l: Color = Color.WHITE
@export var color_leg_r: Color = Color.WHITE
@export var color_leg_l: Color = Color.WHITE

@export_group("Body")
@export var head: PackedScene = preload("res://src/character/styles/base/head_base.tscn")
@export var eye_r: PackedScene = preload("res://src/character/styles/base/eye_r_base.tscn")
@export var eye_l: PackedScene = preload("res://src/character/styles/base/eye_l_base.tscn")
@export var pupil_r: PackedScene = preload("res://src/character/styles/base/pupil_r_base.tscn")
@export var pupil_l: PackedScene = preload("res://src/character/styles/base/pupil_l_base.tscn")
@export var torso: PackedScene = preload("res://src/character/styles/base/torso_base.tscn")
@export var hand_r: PackedScene = preload("res://src/character/styles/base/hand_r_base.tscn")
@export var hand_l: PackedScene = preload("res://src/character/styles/base/hand_l_base.tscn")
@export var leg_r: PackedScene = preload("res://src/character/styles/base/leg_r_base.tscn")
@export var leg_l: PackedScene = preload("res://src/character/styles/base/leg_l_base.tscn")


static func create_style_from_dictionary(style_dict: Dictionary) -> Style:
	var style: Style = Style.new()
	
	for key in style_dict.keys():
		style.set(key, style_dict[key])
	
	return style


func get_all_style_parts_used() -> Array[StylePart]:
	var all_style_parts: Array[StylePart]
	var attributes = get_all_style_attributes()
	
	for value in attributes.values():
		if value is StylePart:
			all_style_parts.append(value)
			
	all_style_parts.make_read_only()
	return all_style_parts


## When iterating over the attributes using `_style.get_all_style_attributes().keys()`,
## use `_style.get_all_style_attributes().get(part_key)` to get the value.
func get_all_style_attributes() -> Dictionary[String, Variant]:
	var all_style_properties: Dictionary[String, Variant]

	for property: Dictionary in get_property_list():
		if property.usage == EXPORTED_SCRIPT_VARIABLE_USAGE_FLAGS:
			if property.class_name == "PackedScene":
				var scene: PackedScene = get(property.name)
				if scene:
					all_style_properties[property.name] = scene.instantiate() as StylePart
				else:
					all_style_properties[property.name] = null
			else:
				# For other properties, just get the value
				all_style_properties[property.name] = get(property.name)

	all_style_properties.make_read_only()
	return all_style_properties
