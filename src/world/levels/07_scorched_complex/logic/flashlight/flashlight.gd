extends PointLight2D

@export var smoothing: float = 0.1


func _ready() -> void:
	Inventory.updated.connect(_on_inventory_updated)

	enabled = Inventory.has_item("07_flashlight")


func _process(delta: float) -> void:
	global_position = global_position.lerp(get_global_mouse_position(), smoothing * 60 * delta)


func _on_inventory_updated(item: String, amount: int) -> void:
	if item == "07_flashlight":
		enabled = amount > 0
