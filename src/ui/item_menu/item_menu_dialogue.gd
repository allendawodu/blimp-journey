class_name ItemMenuDialogue
extends ItemMenu
## Abstract class.

@export var timeline: DialogicTimeline
@export var target: Node
@export var characters: Array[TextBubbleMarker]


func start_dialogue(label) -> void:
	Dialogic.quick_start(timeline, label, characters)
