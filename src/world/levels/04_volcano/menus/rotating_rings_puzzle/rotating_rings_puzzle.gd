extends ItemMenu

const RING: PackedScene = preload("res://src/world/levels/04_volcano/menus/rotating_rings_puzzle/ring.tscn")
const RINGS: Array[Dictionary] = [
	{
		texture = preload("res://src/world/levels/04_volcano/menus/rotating_rings_puzzle/rings/ring_1.png"),
		rotation_snap_step = PI / 3
	},
	{
		texture = preload("res://src/world/levels/04_volcano/menus/rotating_rings_puzzle/rings/ring_2.png"),
		rotation_snap_step = PI / 3
	},
	{
		texture = preload("res://src/world/levels/04_volcano/menus/rotating_rings_puzzle/rings/ring_3.png"),
		rotation_snap_step = 2 * PI / 3
	},
]


func _ready() -> void:
	super()

	%CheckAnswerButton.pressed.connect(_on_check_answer_button_pressed)

	if Inventory.has_item("04_translation_1"):
		%TranslationPage.show()

	for ring: Dictionary in RINGS:
		var new_ring: Ring04 = RING.instantiate()
		new_ring.texture = ring.texture
		new_ring.rotation_snap_step = ring.rotation_snap_step
		%Rings.add_child(new_ring)


func _on_check_answer_button_pressed() -> void:
	var ring_1_rotation: float = %Rings.get_child(0).ring_rotation
	var ring_2_rotation: float = %Rings.get_child(1).ring_rotation
	var ring_3_rotation: float = %Rings.get_child(2).ring_rotation

	if is_equal_approx(ring_1_rotation, ring_2_rotation) and is_equal_approx(ring_1_rotation, ring_3_rotation):
		%CheckAnswerButton.modulate = Color(0, 1, 0, 1)
		await get_tree().create_timer(1).timeout
		resume_game()
		SaverLoader.complete_event("04_ring_puzzle_solved")
	else:
		%CheckAnswerButton.modulate = Color(1, 0, 0, 1)
		await get_tree().create_timer(2).timeout
		%CheckAnswerButton.modulate = Color(1, 1, 1, 1)
