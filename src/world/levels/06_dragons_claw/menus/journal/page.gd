extends Control

@export var corresponding_item: String


func _ready() -> void:
	Inventory.updated.connect(_on_inventory_updated)
	
	if has_node("DragComponent"):
		$DragComponent.drag_started.connect(_on_drag_started)

	visible = Inventory.has_item(corresponding_item)


func _on_drag_started() -> void:
	get_parent().move_child(self, -1)


func _on_inventory_updated(item: String, amount: int) -> void:
	if corresponding_item == item:
		show()
