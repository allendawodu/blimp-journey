extends ItemMenu

const ELEVATOR_POSITION: Vector2 = Vector2(874, 0)

@onready var level: Level = get_tree().get_first_node_in_group("level")


func _ready() -> void:
	super()

	Inventory.updated.connect(_on_inventory_updated)

	%Floor1Button.pressed.connect(_on_floor_button_pressed.bind(1))
	%Floor2Button.pressed.connect(_on_floor_button_pressed.bind(2))
	%Floor3Button.pressed.connect(_on_floor_button_pressed.bind(3))

	%Floor3Button.visible = Inventory.has_item("07_elevator_button")

	# Disable buttons based on the current floor
	if level:
		match level.scene.scene_name:
			"lobby": %Floor1Button.disabled = true
			"floor_2": %Floor2Button.disabled = true
			"floor_3": %Floor3Button.disabled = true


func _on_floor_button_pressed(building_floor: int) -> void:
	resume_game()
	if level:
		match building_floor:
			1: level.change_scene("lobby", ELEVATOR_POSITION)
			2: level.change_scene("floor_2", ELEVATOR_POSITION)
			3: level.change_scene("floor_3", ELEVATOR_POSITION)


func _on_inventory_updated(item: String, amount: int) -> void:
	if item == "07_elevator_button":
		%Floor3Button.show()
