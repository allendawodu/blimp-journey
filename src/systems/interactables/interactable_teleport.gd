@tool
class_name InteractableTeleport
extends Interactable

var destination: Marker2D


func _ready() -> void:
	super()

	destination = find_children("*", "Marker2D", false, false).front()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if find_children("*", "Marker2D", false, false).size() == 0:
		warnings.append("No destination has been set. Please add a Marker2D child to this node.")
	return warnings


func interact() -> void:
	target.global_position = destination.global_position
