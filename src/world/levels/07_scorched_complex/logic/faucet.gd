extends Node2D


func _ready() -> void:
	var level: Level = get_tree().get_first_node_in_group("level")
	if level:
		if level.completed_events.has("07_valve_turned"):
			$InteractableDialogue2.queue_free()
	if Inventory.has_item("07_water_pack"):
		$InteractableDialogue.queue_free()
