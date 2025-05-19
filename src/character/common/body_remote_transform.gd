@tool
class_name BodyRemoteTransform
extends RemoteTransform2D

@export var body: Body


func _ready() -> void:
	body.style_part_updated.connect(force_update_cache)
