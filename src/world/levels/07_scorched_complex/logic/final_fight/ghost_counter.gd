extends Node2D


func _ready() -> void:
	child_exiting_tree.connect(_on_child_exiting_tree)


func _on_child_exiting_tree(child: Node) -> void:
	# Wait for the child to be removed from the tree
	await get_tree().process_frame
	
	if get_child_count() == 0:
		SaverLoader.complete_event("07_final_fight_completed")
