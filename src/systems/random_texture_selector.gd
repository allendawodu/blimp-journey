@tool
class_name RandomTextureSelector
extends Node

@export var textures: Array[Texture]


func _ready() -> void:
	if get_parent() is not Sprite2D:
		printerr("Parent is not of type Sprite2D.")
		return
	
	get_parent().texture = textures.pick_random()