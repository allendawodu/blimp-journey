extends InteractableSceneSwitch


func interact() -> void:
	SaverLoader.complete_event("06_escape_sequence_completed")
	get_tree().get_first_node_in_group("level").change_scene(scene_name, position_in_new_scene)
