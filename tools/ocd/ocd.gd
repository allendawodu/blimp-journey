@tool
extends Node

@export_group("Export Game")
@export_tool_button("Export Game") var export_game: Callable = _export_game
@export var should_deploy_to_firebase: bool

@export_group("Export Level")
@export_tool_button("Export Level") var export_level: Callable = _export_level
@export_dir var level_path: String

@onready var game: Node = $ExportGame
@onready var level: Node = $ExportLevel


func _export_game() -> void:
	game.run(should_deploy_to_firebase)


func _export_level() -> void:
	level.run(level_path)
