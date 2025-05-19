extends Node2D


func _ready() -> void:
	Inventory.updated.connect(_on_inventory_updated)


func _on_inventory_updated(item: String, amount: int) -> void:
	if item == "07_water_pack":
		EventBus.behavior_event_started.emit({
			uuid = "0000",
			type = Behavior.Types.STYLE_CHANGE,
			who = "player",
			index = 0,
		})
