@tool
extends Node2D

@export_node_path("Polygon2D", "CollisionPolygon2D") var target: NodePath:
	set(value):
		target = value
		update_configuration_warnings()


func _ready() -> void:
	var grandparent: Node = get_node_or_null("../..")
	if Engine.is_editor_hint()\
		and target.is_empty()\
		and (grandparent is Polygon2D or grandparent is CollisionPolygon2D):
			target = grandparent.get_path()
			update_configuration_warnings()
		

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_update_polygon()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if target.is_empty():
		warnings.append("Target polygon has not been definied.")
	if not target.is_empty() and "polygon" not in get_node(target):
		warnings.append("Target does not have a polygon property.")
	return warnings


func _update_polygon() -> void:
	if not target.is_empty() and "polygon" in get_node(target):
		set(&"polygon", get_node(target).polygon)
