class_name CardPopup
extends Node2D

var data: Item


func _ready() -> void:
	update_label()

	if data.info:
		%InfoLabel.text = data.info
	else:
		%InfoLabel.get_parent().hide()


func update_label() -> void:
	%DisplayNameLabel.text = data.display_name if not data.display_name.is_empty() else data.name.capitalize()
	
	if data.amount > 1:
		%DisplayNameLabel.text += " (%d)" % data.amount
