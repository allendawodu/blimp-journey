@tool
class_name CloudSpawner
extends Polygon2D

const CLOUD: PackedScene = preload("res://src/world/overworld_map/cloud.tscn")
const NUM_POISSON_RETRIES: int = 10

@export var region: int = -1
@export var min_distance_between_clouds: float = 96


func _ready() -> void:
	if Engine.is_editor_hint():
		self_modulate = Color(self_modulate, 0.5)
		return
	
	# Hide the polygon without hiding the cloud children
	self_modulate = Color(self_modulate, 0)

	# Spawn clouds
	var points: PackedVector2Array = PoissonDiscSampling.generate_points_for_polygon(polygon, min_distance_between_clouds, NUM_POISSON_RETRIES)

	for point: Vector2 in points:
		var new_cloud: Cloud = CLOUD.instantiate()
		new_cloud.global_position = point
		add_child(new_cloud)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		# Set random polygon color
		if color.is_equal_approx(Color.WHITE):
			color = Color.from_ok_hsl(randf(), 0.5, 0.85)
			self_modulate = Color(self_modulate, 0.5)
		
		# Set default region
		if region == -1:
			# NOTE: I should probably check to make sure that no other child has the same index, but this is fine
			region = get_index()


func clear_clouds() -> void:
	const DELAY: float = 3

	var tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	for cloud: Cloud in get_children():
		tween.tween_property(cloud, "position", cloud.start_position + Vector2(randf_range(128, 256), 0), DELAY).set_delay(cloud.get_index() * 0.01)
		tween.tween_property(cloud, "self_modulate", Color(self_modulate, 0), DELAY - 0.5)
		tween.tween_callback(cloud.queue_free).set_delay(DELAY)
	
	EventBus.clouds_cleared.emit(region)
	await get_tree().create_timer(DELAY).timeout
	queue_free()
