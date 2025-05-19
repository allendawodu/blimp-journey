@tool
class_name InteractableSceneSwitch
extends Interactable

@export var scene_name: String
@export var position_in_new_scene: Vector2


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if scene_name.is_empty():
		warnings.push_back("No scene name has been set.")

	return warnings


func interact() -> void:
	get_tree().get_first_node_in_group("level").change_scene(scene_name, position_in_new_scene)
