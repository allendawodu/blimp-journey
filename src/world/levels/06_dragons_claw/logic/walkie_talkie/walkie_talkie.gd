extends Node2D

@export var labels: Dictionary
@export var guide: Character

var current_label: String


func _ready() -> void:
	EventBus.item_examine_started.connect(_on_item_examine_started)

	# Get the value of the first label that ends with "started"
	if not labels.is_empty():
		current_label = labels.values().front()
		for key in labels.keys():
			if key.ends_with("started"):
				current_label = labels[key]
				break


func _on_item_examine_started(item: String) -> void:
	if item != "06_walkie_talkie":
		return
	
	Dialogic.timeline_ended.connect(_on_dialogic_timeline_ended, Object.CONNECT_ONE_SHOT)

	var level: Level = get_tree().get_first_node_in_group("level")
	if level:
		for event: String in level.completed_events:
			if event in labels:
				current_label = labels[event]

	# TODO: Animate
	show()

	var characters: Array[TextBubbleMarker] = [
		get_tree().get_first_node_in_group("player").get_node("TextBubbleMarker"),
	]
	if guide and guide.has_method("pathfind_to_player") and Dialogic.VAR["06"]["is_following_player"]:
		characters.append(guide.get_node("TextBubbleMarker"))
		if level.scene.scene_name == "burial_chamber":
			Dialogic.quick_start("walkie_talkie", "guide_hint", characters)
		else:
			Dialogic.quick_start("walkie_talkie", "guide_found", characters)
	else:
		characters.append($TextBubbleMarker)
		Dialogic.quick_start("walkie_talkie", current_label, characters)


func _on_dialogic_timeline_ended() -> void:
	# TODO: Animate
	hide()
