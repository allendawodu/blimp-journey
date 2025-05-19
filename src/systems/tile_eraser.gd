class_name TileEraser
extends Node

enum ErasePattern { SINGLE, LINE, RECTANGLE }

@export var tiles: Array[Vector2i]
@export var tilemap: TileMapLayer
@export var erase_pattern: ErasePattern = ErasePattern.LINE
@export var game_event: String


func _ready() -> void:
	EventBus.event_list_updated.connect(_on_event_list_updated)
	
	# Update the current label based on events from other scenes
	var level: Level = get_tree().get_first_node_in_group("level")
	if level:
		_on_event_list_updated(level.completed_events)


func _on_event_list_updated(events: Array[String]) -> void:
	if not game_event.is_empty() and game_event in events and is_instance_valid(tilemap):
		match erase_pattern:
			ErasePattern.SINGLE:
				for tile: Vector2i in tiles:
					tilemap.erase_cell(tile)
			ErasePattern.LINE:
				if tiles.size() != 2:
					printerr("[TileEraser] Line erase pattern requires exactly 2 tiles. Aborting...")
					return
				
				var start: Vector2i = tiles[0]
				var end: Vector2i = tiles[1]
				var direction: Vector2i = (end - start).sign()
				var current: Vector2i = start
				
				while current != end:
					tilemap.erase_cell(current)
					current += direction
				tilemap.erase_cell(end)  # Erase the last tile
			ErasePattern.RECTANGLE:
				if tiles.size() != 2:
					printerr("[TileEraser] Rectangle erase pattern requires exactly 2 tiles. Aborting...")
					return
				
				var start: Vector2i = tiles[0]
				var end: Vector2i = tiles[1]
				
				var min_x: int = min(start.x, end.x)
				var max_x: int = max(start.x, end.x)
				var min_y: int = min(start.y, end.y)
				var max_y: int = max(start.y, end.y)
				
				for x in range(min_x, max_x + 1):
					for y in range(min_y, max_y + 1):
						tilemap.erase_cell(Vector2i(x, y))
