class_name BackContinue
extends Control

@export var previous_scene: PackedScene
@export var next_scene: PackedScene


func _ready() -> void:
	%BackButton.pressed.connect(_on_back_button_pressed)
	%ContinueButton.pressed.connect(_on_continue_button_pressed)


func _on_back_button_pressed() -> void:
	await SaverLoader.save_game()
	get_tree().change_scene_to_packed(previous_scene)


func _on_continue_button_pressed() -> void:
	await SaverLoader.save_game()
	get_tree().change_scene_to_packed(next_scene)
