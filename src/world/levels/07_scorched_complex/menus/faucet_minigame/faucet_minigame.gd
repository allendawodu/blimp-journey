extends ItemMenu


func _ready() -> void:
	super()

	%Button.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	Inventory.remove_item("07_water_pack")
	Inventory.add_item("07_water_pack_filled")
	SaverLoader.complete_event("07_water_pack_filled")
	%Button.disabled = true

	resume_game()

	get_tree().get_first_node_in_group("player").get_node("Phone")._on_item_examine_started("07_phone")
