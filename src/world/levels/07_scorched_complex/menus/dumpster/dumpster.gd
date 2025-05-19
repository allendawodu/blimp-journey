extends ItemMenu


func _ready() -> void:
	super()

	%Button.pressed.connect(_on_button_pressed)
	%Button.disabled = Inventory.has_item("07_glass_breaker")


func _on_button_pressed() -> void:
	Inventory.add_item("07_glass_breaker")
	SaverLoader.complete_event("07_glass_breaker_taken")
	%Button.disabled = true
