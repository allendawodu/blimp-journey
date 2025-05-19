extends Subscene

@export var labels: Array[RichTextLabel]

@onready var continue_button: Button = $MarginContainer/VBoxContainer/ContinueButton


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_button_pressed)
	
	for label in labels:
		label.meta_clicked.connect(_on_body_label_meta_clicked)


func activate() -> void:
	pass


func _on_body_label_meta_clicked(meta: Variant) -> void:
	if meta is not String:
		return
	
	OS.shell_open(meta)


func _on_continue_button_pressed() -> void:
	continue_button.disabled = true
	owner.switch_to_next_scene()
