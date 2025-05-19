class_name PathBuilder
extends Node2D

const POINT_VISUALIZER: PackedScene = preload("res://src/systems/pathfinding/point_visualizer.tscn")
const EMPTY_CELL: int = -1
## Max number of tiles to check to determine if the character can drop to it
const FALL_TILE_SCAN_DEPTH_MAX: int = 500
const JUMP_HEIGHT_MAX: int = 8
const JUMP_LENGTH_MAX: int = 9

@export var tilemap_ground: TileMapLayer
@export var tilemap_platform: TileMapLayer
@export var tilemap_custom: TileMapLayer
@export var manual_connections: Array[PointConnection]
@export var disabled_connections: Array[PointConnection]

var _astar: AStar2D = AStar2D.new()
var _points: Array[Point]
var _debug_lines: Array[Dictionary]

@onready var _debug_path: Line2D = $DebugPath


func _ready() -> void:
	_build_graph()


func _draw() -> void:
	for line: Dictionary in _debug_lines:
		draw_line(line.from, line.to, line.color)


func get_platform_2d_path(from: Vector2, to: Vector2) -> Array[Point]:
	var path: Array[Point] = []
	var id_path: PackedInt64Array = _astar.get_id_path(_astar.get_closest_point(from), _astar.get_closest_point(to), true)

	for id: int in id_path:
		var point: Point = _get_point_by_id(id)
		
		if id_path.size() >= 2 and id == id_path[0]:
			var second_point: Point = _get_point_by_id(id_path[1])

			if from.distance_to(second_point.global_position) < from.distance_to(point.global_position):
				continue
		
		path.append(point)
	
	return path


func _build_graph() -> void:
	var used_cells: Dictionary = {}  # Set
	var all_used_cells: Array[Vector2i] = tilemap_ground.get_used_cells() + tilemap_platform.get_used_cells() + tilemap_custom.get_used_cells()

	for tile: Vector2i in all_used_cells:
		used_cells[tile] = null
	
	for tile in used_cells.keys():
		# Ignore ground tiles that are not surface-level
		if not _is_tile_neighbor_empty(tilemap_ground, tile, TileSet.CELL_NEIGHBOR_TOP_SIDE):
			continue
		
		_add_left_edge_point(tile)
		_add_right_edge_point(tile)
		_add_left_wall_point(tile)
		_add_right_wall_point(tile)
	
	var non_ground_cells: Array[Vector2i] = tilemap_platform.get_used_cells() + tilemap_custom.get_used_cells()
	for tile: Vector2i in non_ground_cells:
		_add_fall_point(tile)
	
	# Draw lines
	for point: Point in _points:
		_connect_horizontal_points(point)
		_connect_jump_points(point)
		_connect_fall_points(point)
		_connect_staircase_points(point)
	
	# Manual connections
	for connection: PointConnection in manual_connections:
		var point_a: Point = _get_point_by_id(connection.from_id)
		var point_b: Point = _get_point_by_id(connection.to_id)
		_astar.connect_points(point_a.id, point_b.id, connection.is_bidirectional)
		_draw_debug_line(point_a.global_position, point_b.global_position, Color.RED)
	
	for connection: PointConnection in disabled_connections:
		# NOTE: Doesn't remove debug lines
		_astar.disconnect_points(connection.from_id, connection.to_id, connection.is_bidirectional)


func draw_debug_path(path: Array[Point]) -> void:
	_debug_path.clear_points()
	
	for point: Point in path:
		_debug_path.add_point(point.global_position)


#region Add Points

func _add_edge_point(tile: Vector2i, neighbor: TileSet.CellNeighbor, property: Point.Property) -> void:
	var _tilemap_layers: Array[TileMapLayer] = [tilemap_ground, tilemap_platform, tilemap_custom]
	var is_empty: bool = true

	for layer: TileMapLayer in _tilemap_layers:
		if not _is_tile_neighbor_empty(layer, tile, neighbor):
			is_empty = false
			break
	
	if is_empty:
		var tile_above: Vector2i = tile + Vector2i.UP
		var point: Point = _get_or_create_point(tile_above)
		point.properties.append(property)
		_astar.add_point(point.id, point.global_position)
		_add_point_visualizer(point)


func _add_wall_point(tile: Vector2i, neighbor: TileSet.CellNeighbor, property: Point.Property) -> void:
	var _tilemap_layers: Array[TileMapLayer] = [tilemap_ground, tilemap_platform, tilemap_custom]
	var has_wall: bool = false

	for layer: TileMapLayer in _tilemap_layers:
		if not _is_tile_neighbor_empty(layer, tile, neighbor):
			has_wall = true
			break
	
	if has_wall:
		var tile_above: Vector2i = tile + Vector2i.UP
		var point: Point = _get_or_create_point(tile_above)
		point.properties.append(property)
		_astar.add_point(point.id, point.global_position)
		_add_point_visualizer(point)


func _add_left_edge_point(tile: Vector2i) -> void:
	_add_edge_point(tile, TileSet.CELL_NEIGHBOR_LEFT_SIDE, Point.Property.IS_LEFT_EDGE)


func _add_right_edge_point(tile: Vector2i) -> void:
	_add_edge_point(tile, TileSet.CELL_NEIGHBOR_RIGHT_SIDE, Point.Property.IS_RIGHT_EDGE)


func _add_left_wall_point(tile: Vector2i) -> void:
	_add_wall_point(tile, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER, Point.Property.IS_LEFT_WALL)


func _add_right_wall_point(tile: Vector2i) -> void:
	_add_wall_point(tile, TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER, Point.Property.IS_RIGHT_WALL)


func _add_fall_point(tile: Vector2i) -> void:
	var fall_tile: Variant = _scan_for_tile(tile + Vector2i.DOWN, Vector2i.DOWN, FALL_TILE_SCAN_DEPTH_MAX)

	if fall_tile == null:
		return
	
	var tile_above: Vector2i = fall_tile + Vector2i.UP
	var point: Point = _get_or_create_point(tile_above)
	point.properties.append(Point.Property.IS_FALL_TILE)
	_astar.add_point(point.id, point.global_position)
	_add_point_visualizer(point)
		
#endregion


#region Connect Points

func _create_intermediate_points(p1: Point, closest_point: Point) -> void:
	const INTERMEDIATE_POINT_SPACING: int = 1  # Adjust this constant as needed
	for x: int in range(p1.local_position.x, closest_point.local_position.x, INTERMEDIATE_POINT_SPACING):
		var intermediate_point: Point = _get_or_create_point(Vector2i(x + 1, p1.local_position.y))
		intermediate_point.properties.append(Point.Property.IS_POSITION_POINT)
		_astar.add_point(intermediate_point.id, intermediate_point.global_position)
		_astar.connect_points(p1.id, intermediate_point.id)
		_draw_debug_line(p1.global_position, intermediate_point.global_position)
		_add_point_visualizer(intermediate_point)
		p1 = intermediate_point


func _connect_horizontal_points(p1: Point) -> void:
	if p1.has_any_property([Point.Property.IS_LEFT_EDGE, Point.Property.IS_LEFT_WALL, Point.Property.IS_FALL_TILE]):
		var closest_point: Point = null
		for p2: Point in _points:
			if p1 == p2:
				continue
			
			if p2.has_any_property([Point.Property.IS_RIGHT_EDGE, Point.Property.IS_RIGHT_WALL, Point.Property.IS_FALL_TILE]) and p1.local_position.y == p2.local_position.y and p1.local_position.x < p2.local_position.x:
				if closest_point == null:
					closest_point = p2
					continue
				
				if p2.local_position.x < closest_point.local_position.x:
					closest_point = p2
		
		if closest_point != null:
			# Don't connect obstructed points
			for x in range(p1.local_position.x, closest_point.local_position.x):
				var tile_pos: Vector2i = Vector2i(x, p1.local_position.y)
				var is_obstructed: bool = (
					(not _is_tile_neighbor_empty(tilemap_ground, tile_pos, TileSet.CELL_NEIGHBOR_RIGHT_SIDE) or
					_is_tile_neighbor_empty(tilemap_ground, tile_pos, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)) and
					(not _is_tile_neighbor_empty(tilemap_platform, tile_pos, TileSet.CELL_NEIGHBOR_RIGHT_SIDE) or
					_is_tile_neighbor_empty(tilemap_platform, tile_pos, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)) and
					(not _is_tile_neighbor_empty(tilemap_custom, tile_pos, TileSet.CELL_NEIGHBOR_RIGHT_SIDE) or
					_is_tile_neighbor_empty(tilemap_custom, tile_pos, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE))
				)
				
				if is_obstructed:
					return
			
			_create_intermediate_points(p1, closest_point)

			_astar.connect_points(p1.id, closest_point.id)
			_draw_debug_line(p1.global_position, closest_point.global_position)


func _connect_jump_points(p1: Point) -> void:
	for p2: Point in _points:
		if p1 == p2:
			continue
		
		var is_right_to_left_jump: bool = p1.properties.has(Point.Property.IS_RIGHT_EDGE) and p2.properties.has(Point.Property.IS_LEFT_EDGE) and p1.local_position.x < p2.local_position.x
		var is_left_to_right_jump: bool = p1.properties.has(Point.Property.IS_LEFT_EDGE) and p2.properties.has(Point.Property.IS_RIGHT_EDGE) and p1.local_position.x > p2.local_position.x
		
		if (is_right_to_left_jump or is_left_to_right_jump) and absi(p2.local_position.y - p1.local_position.y) <= JUMP_HEIGHT_MAX:
			if absi(p2.local_position.x - p1.local_position.x) < JUMP_LENGTH_MAX:
				_astar.connect_points(p1.id, p2.id)
				_draw_debug_line(p1.global_position, p2.global_position)
		

func _connect_fall_points(p1: Point) -> void:
	var non_ground_cells: Array[Vector2i] = tilemap_platform.get_used_cells() + tilemap_custom.get_used_cells()
	if p1.local_position + Vector2i.DOWN in non_ground_cells:
		var fall_tile: Variant = _scan_for_tile(p1.local_position + Vector2i.DOWN, Vector2i.DOWN, FALL_TILE_SCAN_DEPTH_MAX)

		if fall_tile == null:
			return
		
		var p2: Point = _get_point_or_null(fall_tile + Vector2i.UP)

		if p2 == null:
			return
		
		if absi(p2.local_position.y - p1.local_position.y) <= JUMP_HEIGHT_MAX:
			_astar.connect_points(p1.id, p2.id)
			_draw_debug_line(p1.global_position, p2.global_position)
		else:
			_astar.connect_points(p1.id, p2.id, false)
			_draw_debug_line(p1.global_position, p2.global_position, Color.YELLOW)


func _connect_staircase_points(p1: Point) -> void:
	if p1.has_any_property([Point.Property.IS_LEFT_EDGE, Point.Property.IS_RIGHT_EDGE]) and p1.local_position + Vector2i.DOWN in tilemap_ground.get_used_cells():
		var direction: Vector2i = Vector2i.LEFT if p1.properties.has(Point.Property.IS_LEFT_EDGE) else Vector2i.RIGHT
		var fall_tile: Variant = _scan_for_tile(p1.local_position + Vector2i.DOWN + direction, Vector2i.DOWN, FALL_TILE_SCAN_DEPTH_MAX)

		if fall_tile == null:
			return
		
		var p2: Point = _get_point_or_null(fall_tile + Vector2i.UP)

		if p2 == null:
			return
		
		if absi(p2.local_position.y - p1.local_position.y) <= JUMP_HEIGHT_MAX:
			_astar.connect_points(p1.id, p2.id)
			_draw_debug_line(p1.global_position, p2.global_position)
		else:
			_astar.connect_points(p1.id, p2.id, false)
			_draw_debug_line(p1.global_position, p2.global_position, Color.YELLOW)

#endregion


#region Helpers

func _scan_for_tile(start_tile: Vector2i, direction: Vector2i, max_depth: int) -> Variant:
	var tile: Vector2i = start_tile
	for i: int in range(max_depth):
		if not _is_tile_neighbor_empty(tilemap_platform, tile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE) \
			or not _is_tile_neighbor_empty(tilemap_ground, tile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE):
				return tile + direction
		tile += direction
	return null


func _add_point_visualizer(point: Point) -> void:
	var new_point_visualizer: PointVisualizer = POINT_VISUALIZER.instantiate()
	new_point_visualizer.global_position = point.global_position
	new_point_visualizer.target = point
	add_child(new_point_visualizer)


func _get_point_or_null(tile: Vector2i) -> Point:
	for point: Point in _points:
		if tile == point.local_position:
			return point
	return null


func _get_or_create_point(tile: Vector2i) -> Point:
	for point: Point in _points:
		if tile == point.local_position:
			return point
	var new_point: Point = Point.new(_astar.get_available_point_id(), tile)
	_points.append(new_point)
	return new_point


func _is_tile_neighbor_empty(layer: TileMapLayer, tile: Vector2i, neighbor: TileSet.CellNeighbor) -> bool:
	return layer.get_cell_source_id(layer.get_neighbor_cell(tile, neighbor)) == EMPTY_CELL


func _draw_debug_line(p_from: Vector2, p_to: Vector2, p_color: Color = Color(0, 1, 0)) -> void:
	_debug_lines.append({
		"from": p_from,
		"to": p_to,
		"color": p_color,
	})


## Create custom points that refer to the character's actual desired start and end positions.
func _create_position_point(p_global_position: Vector2) -> Point:
	var new_point: Point = Point.new(-999, tilemap_ground.local_to_map(p_global_position))
	new_point.properties.append(Point.Property.IS_POSITION_POINT)

	var is_tile_neighbor_empty: Callable = func(neighbor: TileSet.CellNeighbor) -> bool:
		return not (_is_tile_neighbor_empty(tilemap_ground, new_point.local_position, neighbor) \
			and _is_tile_neighbor_empty(tilemap_platform, new_point.local_position, neighbor))

	if not is_tile_neighbor_empty.call(TileSet.CELL_NEIGHBOR_BOTTOM_SIDE):

		if not is_tile_neighbor_empty.call(TileSet.CELL_NEIGHBOR_LEFT_SIDE):
			new_point.properties.append(Point.Property.IS_LEFT_WALL)

		if not is_tile_neighbor_empty.call(TileSet.CELL_NEIGHBOR_RIGHT_SIDE):
			new_point.properties.append(Point.Property.IS_RIGHT_WALL)

		if is_tile_neighbor_empty.call(TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER):
			new_point.properties.append(Point.Property.IS_LEFT_EDGE)

		if is_tile_neighbor_empty.call(TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER):
			new_point.properties.append(Point.Property.IS_RIGHT_EDGE)
	
	return new_point
		

func _get_point_by_id(id: int) -> Point:
	for point: Point in _points:
		if point.id == id:
			return point
	return null

#endregion


class Point:
	enum Property {IS_FALL_TILE, IS_LEFT_EDGE, IS_RIGHT_EDGE, IS_LEFT_WALL, IS_RIGHT_WALL, IS_POSITION_POINT}

	const CELL_SIZE: float = 64
	const OFFSET: Vector2 = Vector2(32, 32)
	
	var id: int
	var properties: Array[Property]
	## Read-only. Use [method PathBuilder.Point.set_global_position] to set this value.
	var global_position: Vector2
	var local_position: Vector2i:
		set(value):
			local_position = value
			global_position = value * CELL_SIZE + OFFSET


	func _init(p_id: int, p_position: Vector2i) -> void:
		id = p_id
		local_position = p_position

	
	func has_any_property(properties_to_check: Array[Property]) -> bool:
		for property: Property in properties_to_check:
			if property in properties:
				return true
		return false
	
	
	func set_global_position(p_global_position: Vector2) -> void:
		local_position = ((global_position - OFFSET) / CELL_SIZE).floor()
