@tool
class_name InteractableCollectible
extends Interactable

@export var item_name: String:
	set(value):
		item_name = value
		update_configuration_warnings()
@export var free_if_already_collected: bool = true


func _ready() -> void:
	super()

	if Engine.is_editor_hint():
		return
	
	body_entered.connect(interact.unbind(1))

	if free_if_already_collected and Inventory.has_item(item_name):
		target.queue_free()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if item_name.is_empty():
		warnings.append("Item name is empty.")
	return warnings


func interact() -> void:
	Inventory.add_item(item_name)
	target.queue_free()
