extends Control

const PIECE: PackedScene = preload("res://src/world/levels/06_dragons_claw/menus/mural/piece.tscn")

@export var pieces_group: ResourceGroup


func _ready() -> void:
	%Brush.get_node("DragComponent").drag_ended.connect(_on_drag_ended)

	create_pieces.call_deferred()


func create_pieces() -> void:
	var clean_pieces: Array = pieces_group.load_matching([], ["**dirty**"])
	var dirty_pieces: Array = pieces_group.load_matching(["**dirty**"], [])

	for i in range(clean_pieces.size()):
		var piece: TextureRect = PIECE.instantiate()
		piece.name = "Piece%02d" % (i + 1)
		piece.texture_clean = clean_pieces[i]
		piece.texture_dirty = dirty_pieces[i]
		piece.position += Vector2(randf_range(-600, 400), 330)
		piece.solve_position = %ReferencePieces.get_child(i).global_position
		piece.piece_placed.connect(_on_drag_ended)
		add_child(piece)


func _on_drag_ended() -> void:
	var max_filled: int = 0
	var total_count: int = 0
	var correct_position: int = 0

	for piece in get_children():
		max_filled += piece.surface_area_total
		total_count += piece.surface_area_cleaned
		correct_position += 1 if piece.get_node("DragComponent").disabled else 0
	
	prints(1.0 * total_count / max_filled)
	
	if total_count >= max_filled * 0.9 and correct_position == get_child_count():
		print("Puzzle solved!")
		owner.resume_game()
		SaverLoader.complete_event("06_mural_completed")
		owner.start_dialogue("mural")
