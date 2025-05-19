extends ItemMenu

@export var answer: Array[String] = ["🔓", "K", "C", "L", "N"]


func _ready() -> void:
	super()
	
	%CheckButton.pressed.connect(_on_check_button_pressed)

	# DEBUG
	# %Page.show()


func _on_check_button_pressed() -> void:
	if answer.size() != %Dials.get_child_count():
		printerr("[TreasureChest] Answer array size does not match dials count")
		return
	
	for i: int in %Dials.get_child_count():
		var dial: Button = %Dials.get_child(i)
		if dial.text != answer[i]:
			return

	resume_game()
	Inventory.add_item("06_treasure")
	SaverLoader.complete_event("06_chest_unlocked")
