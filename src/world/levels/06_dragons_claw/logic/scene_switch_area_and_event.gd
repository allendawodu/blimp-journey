extends Area2D

@export var scene_name: String
@export var position_in_new_scene: Vector2


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if scene_name.is_empty():
		warnings.push_back("No scene name has been set.")

	return warnings


func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	
	SaverLoader.complete_event("06_escape_sequence_completed")
	get_tree().get_first_node_in_group("level").change_scene.call_deferred(scene_name, position_in_new_scene)
