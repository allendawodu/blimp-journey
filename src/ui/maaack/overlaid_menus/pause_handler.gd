class_name PauseHandler
extends TextureButton

@export var pause_menu: Control


func _ready() -> void:
	pressed.connect(pause_game)

	EventBus.about_to_pause.connect(hide.unbind(1))
	EventBus.about_to_resume.connect(show.unbind(1))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause_game()


func _process(delta: float) -> void:
	modulate = Color.WHITE if is_hovered() else Color(1, 1, 1, 0.5)


func pause_game() -> void:
	if get_tree().paused:
		return

	get_viewport().set_input_as_handled()	
	EventBus.about_to_pause.emit("pause_handler")
	pause_menu.visible = true
	get_tree().paused = true
