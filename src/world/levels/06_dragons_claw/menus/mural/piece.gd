extends TextureRect

signal piece_placed

const SOLVE_TOLERANCE: float = 50.0
const BRUSH_WIDTH: float = 30.0
const BRUSH_HEIGHT: float = 40.0

@export var solve_position: Vector2
@export var texture_clean: Texture2D:
	set(value):
		texture = value
		material.set_shader_parameter("clean_texture", value)
@export var texture_dirty: Texture2D:
	set(value):
		material.set_shader_parameter("dirty_texture", value)

var mask_image: Image
var dirt_mask: ImageTexture
var surface_area_cleaned: int
var surface_area_total: int


func _ready() -> void:
	get_tree().get_root().size_changed.connect(_on_window_resized)

	$DragComponent.drag_started.connect(_on_drag_started)
	$DragComponent.drag_ended.connect(_on_drag_ended)

	$DragComponent.create_click_mask(texture)
	surface_area_total = $DragComponent.texture_click_mask.get_true_bit_count()

	# Create dirt mask
	mask_image = Image.create(texture.get_width(), texture.get_height(), false, Image.FORMAT_L8)
	mask_image.fill(Color.WHITE)

	dirt_mask = ImageTexture.create_from_image(mask_image)

	material.set_shader_parameter("dirt_mask", dirt_mask)


func _input(event: InputEvent) -> void:
	var brush = get_parent().get_node("%Brush")
	if event is InputEventMouseMotion and brush.drag_component.is_dragging:
		var brush_head_position: Vector2 = $Node2D.to_local(brush.brush_head.global_position)

		for x in range(-BRUSH_WIDTH, BRUSH_WIDTH + 1):
			for y in range(-BRUSH_HEIGHT, BRUSH_HEIGHT + 1):
				var dx = x + brush_head_position.x
				var dy = y + brush_head_position.y

				if dx >= 0 and dx < mask_image.get_width() and dy >= 0 and dy < mask_image.get_height() and mask_image.get_pixel(dx, dy).is_equal_approx(Color.WHITE) and $DragComponent.texture_click_mask.get_bit(dx, dy):
					mask_image.set_pixel(dx, dy, Color.BLACK)
					surface_area_cleaned += 1
		
		dirt_mask.update(mask_image)
		material.set_shader_parameter("dirt_mask", dirt_mask)


func _on_drag_started() -> void:
	# Move to top
	get_parent().move_child(self, get_parent().get_child_count() - 1)


func _on_drag_ended() -> void:
	# Check if the piece is in the correct position
	if global_position.distance_to(solve_position) < SOLVE_TOLERANCE:
		global_position = solve_position
		$DragComponent.disabled = true
		$DragComponent.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Move to bottom
		get_parent().move_child(self, 0)
		piece_placed.emit()


func _on_window_resized() -> void:
	solve_position = get_parent().get_node("%ReferencePieces").get_node("%s" % name).global_position
