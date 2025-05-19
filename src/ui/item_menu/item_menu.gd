class_name ItemMenu
extends Panel
## Abstract class.

## The item that this menu is for.
## Can be empty if this menu is for a non-item interaction.
@export var corresponding_item: String


func _ready() -> void:
	EventBus.item_examine_started.connect(_on_item_examine_started)
	%CloseButton.pressed.connect(_on_close_button_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		resume_game()


func interact() -> void:
	# Pause the game
	EventBus.about_to_pause.emit("item_menu")
	get_tree().paused = true
	show()


func resume_game() -> void:
	EventBus.about_to_resume.emit("item_menu")
	get_tree().paused = false
	hide()


func _on_close_button_pressed() -> void:
	resume_game()


func _on_item_examine_started(item: String) -> void:
	if not corresponding_item.is_empty() and item == corresponding_item:
		interact()
