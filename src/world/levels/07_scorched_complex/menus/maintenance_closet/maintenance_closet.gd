extends ItemMenu

const FUSE: Texture2D = preload("res://src/world/levels/07_scorched_complex/menus/maintenance_closet/assets/fuse.png")


func _ready() -> void:
	super()

	Inventory.updated.connect(_on_inventory_updated)
	
	%Wrench.pressed.connect(_on_wrench_pressed)
	%FuseLeft.pressed.connect(_on_fuse_left_pressed)
	%FuseRight.pressed.connect(_on_fuse_right_pressed)
	
	%Wrench.visible = not Inventory.has_item("07_wrench")

	var level: Level = get_tree().get_first_node_in_group("level")
	if level:
		if level.completed_events.has("07_fuse_left_inserted"):
			%FuseLeft.texture_normal = FUSE
			%FuseLeft.disabled = true
		if level.completed_events.has("07_fuse_right_inserted"):
			%FuseRight.texture_normal = FUSE
			%FuseRight.disabled = true


func _on_inventory_updated(item: String, amount: int) -> void:
	if item == "07_fuse_left":
		%FuseLeft.disabled = amount == 0
	elif item == "07_fuse_right":
		%FuseRight.disabled = amount == 0
	elif item == "07_wrench":
		%Wrench.visible = amount > 0


func _on_wrench_pressed() -> void:
	Inventory.add_item("07_wrench")
	%Wrench.hide()


func _on_fuse_left_pressed() -> void:
	Inventory.remove_item("07_fuse_left")
	SaverLoader.complete_event("07_fuse_left_inserted")
	%FuseLeft.texture_normal = FUSE
	%FuseLeft.disabled = true


func _on_fuse_right_pressed() -> void:
	Inventory.remove_item("07_fuse_right")
	SaverLoader.complete_event("07_fuse_right_inserted")
	%FuseRight.texture_normal = FUSE
	%FuseRight.disabled = true
