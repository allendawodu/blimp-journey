extends Control

const OPTIONS_MENU_MINI: PackedScene = preload("res://src/ui/maaack/overlaid_menus/mini_options_overlaid_menu.tscn")

var authenticate_scene: PackedScene


func _ready() -> void:
	%ResumeButton.pressed.connect(_on_resume_button_pressed)
	%SettingsButton.pressed.connect(_on_settings_button_pressed)
	%ExitButton.pressed.connect(_on_exit_button_pressed)
	
	# For some reason, I can't preload this scene
	# My guess is that there's a cyclical dependency
	authenticate_scene = load("res://src/ui/account_management/authentication/authenticate.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		_on_resume_button_pressed()
		get_viewport().set_input_as_handled()


func _on_resume_button_pressed() -> void:
	visible = false
	EventBus.about_to_resume.emit("pause_menu")
	get_tree().paused = false


func _on_settings_button_pressed() -> void:
	var options_scene = OPTIONS_MENU_MINI.instantiate()
	add_child(options_scene)


func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	Dialogic.end_timeline()
	get_tree().change_scene_to_packed(authenticate_scene)
