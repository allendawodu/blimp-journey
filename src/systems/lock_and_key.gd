class_name LockAndKey
extends Node

## Inventory item that acts as the key.
@export var key: String
## Node (usually an InteractableDialogue) that acts as the lock.
@export var lock: Node


func _ready() -> void:
	Inventory.updated.connect(_on_inventory_updated)

	if Inventory.has_item(key):
		unlock()


func unlock() -> void:
	lock.queue_free()
	Inventory.updated.disconnect(_on_inventory_updated)


func _on_inventory_updated(item: String, amount: int) -> void:
	if item == key and amount > 0:
		unlock()
