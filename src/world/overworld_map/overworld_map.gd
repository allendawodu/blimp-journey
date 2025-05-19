extends Node

@export var clear_clouds_conditions: Array[CloudClearCondition]


func _ready() -> void:
	add_to_group("persist")

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	SaverLoader.load_game()


func clear_clouds(region: int) -> void:
	for cloud_spawner: CloudSpawner in %CloudSpawners.get_children():
		if cloud_spawner.region == region:
			cloud_spawner.clear_clouds()
			return
	
	printerr("Nothing happened... Check if the region is correct.")


func save_data(document: FirestoreDocument) -> void:
	pass


func load_data(document: FirestoreDocument) -> void:
	for condition: CloudClearCondition in clear_clouds_conditions:
		var completed_events: Array = document.get_field("levels.%02d.completed_events" % condition.level_code, [])
		if completed_events.has(condition.final_event):
			clear_clouds(condition.region_to_clear)
