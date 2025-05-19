class_name PointVisualizer
extends Node2D

var target: PathBuilder.Point


func _ready() -> void:
	# Create tooltip
	var text: String = ""
	text += "ID: " + str(target.id) + "\n"
	text += "Local Postion: " + str(target.local_position) + "\n"
	text += "Global Position: " + str(target.global_position) + "\n"
	for property in target.properties:
		text += target.Property.keys()[property] + "\n"
	$TextureRect.tooltip_text = text
