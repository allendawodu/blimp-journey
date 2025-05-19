@tool
extends Node

@export_group("Import Style")
@export_tool_button("Import Style") var import_style: Callable = _import_style
@export_tool_button("Refresh Filesystem") var refresh_filesystem: Callable = _refresh_filesystem
@export_global_file("*.svg") var global_file_path: String

@onready var importer: Node = $Importer


func _import_style() -> void:
	importer.run(global_file_path)


func _refresh_filesystem() -> void:
	EditorInterface.get_resource_filesystem().scan()
	print("Filesystem refreshed.")
