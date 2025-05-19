extends ItemMenu

const TILE: PackedScene = preload("res://src/world/levels/04_volcano/menus/tile_puzzle/tile.tscn")
const LIGHT: PackedScene = preload("res://src/world/levels/04_volcano/menus/tile_puzzle/light.tscn")
const RUNES_GROUP: ResourceGroup = preload("res://src/world/levels/04_volcano/menus/tile_puzzle/rune_group.tres")
const OFFSET: Vector2 = Vector2(64, 64)

## The number of keys specifies the number of rounds.[br]
## Each value should be a multiple of 4.[br]
## round_num: int : num_tiles: int.
@export var num_tiles_per_round: Dictionary = {
	1: 16,
	2: 20,
	3: 24,
}

var current_round: int = 1
var current_active_tile: Tile04
var light: PointLight2D

var _match_numbers: Array[int]
var _textures: Array[Texture]


func _ready() -> void:
	super()

	# Load the textures
	RUNES_GROUP.load_all_into(_textures)

	# Create the light
	light = LIGHT.instantiate()
	light.enabled = false
	add_child(light)

	reset()


func reset() -> void:
	light.enabled = false

	# Clear the grid
	%Grid.get_children().map(func(child): child.queue_free())
	%Grid.columns = num_tiles_per_round[current_round] / 4

	# Shuffle the match numbers
	_match_numbers.clear()

	for i: int in range(num_tiles_per_round[current_round] / 2):
		_match_numbers.append(i)
		_match_numbers.append(i)
	
	_match_numbers.shuffle()

	# Create the tiles
	for i: int in range(num_tiles_per_round[current_round]):
		var tile: Tile04 = TILE.instantiate()

		tile.match_number = _match_numbers[i]
		tile.texture = _textures[_match_numbers[i]]

		tile.pressed.connect(_on_tile_pressed.bind(tile))
		
		%Grid.add_child(tile)


func _on_tile_pressed(tile: Tile04) -> void:
	# First tile pressed
	if current_active_tile == null:
		current_active_tile = tile

		_move_light_to(tile)
	# No match
	elif current_active_tile == tile or current_active_tile.match_number != tile.match_number:
		current_active_tile = tile

		_move_light_to(tile)

	# Match found
	else:
		current_active_tile.disable()
		current_active_tile.pressed.disconnect(_on_tile_pressed)

		tile.disable()
		tile.pressed.disconnect(_on_tile_pressed)

		current_active_tile = null
		
		_move_light_to(tile)

		# Check if the puzzle is completed
		if %Grid.get_children().all(func(child): return child.disabled):
			current_round += 1

			# End puzzle
			if current_round > num_tiles_per_round.size():
				resume_game()
				SaverLoader.complete_event("04_tile_puzzle_solved")
			# Next round
			else:
				reset()


func _move_light_to(tile: Tile04) -> void:
	light.global_position = tile.global_position + OFFSET
	light.enabled = true
