class_name PageButton
extends Button

signal clicked(page_to_show: Control)

@export var page_to_show: Control


func _ready() -> void:
	pressed.connect(clicked.emit.bind(page_to_show))
