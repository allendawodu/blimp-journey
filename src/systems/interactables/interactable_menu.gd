@tool
class_name InteractableMenu
extends Interactable

@export_node_path("Control") var menu_path: NodePath


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if menu_path.is_empty():
		warnings.append("Menu path is empty.")
	return warnings


func interact() -> void:
	var menu: Control = get_node_or_null(menu_path)

	if not is_instance_valid(menu):
		printerr("[InteractableMenu] Menu not found at path: %s" % menu_path)
		return
	
	menu.interact()
