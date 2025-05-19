@tool
class_name StylePart
extends Node2D

@export var style_name: String
@export var part: CharacterParts.Part = CharacterParts.Part.NONE


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()

	if style_name.is_empty():
		warnings.append("StylePart name is empty.")
	if part == CharacterParts.Part.NONE:
		warnings.append("StylePart is not set.")
	
	return warnings


func set_color(color: Color) -> void:
	self_modulate = color
	
	for child: Node in get_children():
		if child is not CanvasItem or child.owner != self:
			continue
		
		child.self_modulate = color
