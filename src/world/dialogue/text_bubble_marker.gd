class_name TextBubbleMarker
extends Marker2D

@export var character: DialogicCharacter


func _process(delta: float) -> void:
	# CLEANUP
	if owner is Character:
		position.x = 10 if %Animation.direction > 0 else -10
