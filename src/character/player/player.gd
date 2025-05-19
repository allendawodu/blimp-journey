@tool
class_name Player
extends Character


func _ready() -> void:
	if Engine.is_editor_hint():
		set_style(style)


## Called by cards.
## Try to interact with the interactable the item corresponds to.
func attempt_item_interaction(interactable: Interactable, item_data: ItemUseable) -> bool:
	if global_position.distance_to(interactable.global_position) < item_data.max_distance_to_interactable:
		%CanInteract.go_to_interactable(interactable)
		return true
		
	return false


func kill() -> void:
	# FIXME: In production, I would just reload the current scene
	velocity = Vector2.ZERO
	_chart.send_event("ground")
	global_position = Vector2.ZERO
	_chart.send_event("fall")
