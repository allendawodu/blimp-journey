extends Node2D

const WATER: PackedScene = preload("res://src/world/levels/07_scorched_complex/logic/water_pack/water.tscn")
const UI: PackedScene = preload("res://src/world/levels/07_scorched_complex/logic/water_pack/tank_level.tscn")

@export var projectile_velocity_multiplier: float = 2
@export var damage_per_frame: float = 100
@export var rate_of_depletion: float = 0.1
@export var refill_rate: float = 0.5
## Controls the randomness of shots (0 = perfect accuracy)
@export var spray_factor: float = 0.2

@onready var player: Player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	Inventory.updated.connect(_on_inventory_updated)

	if Inventory.has_item("07_water_pack_filled"):
		_add_ui()


func _process(delta: float) -> void:
	var is_rmb_down: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	var is_space_down: bool = Input.is_physical_key_pressed(KEY_SPACE)
	if (is_rmb_down or is_space_down) and Inventory.has_item("07_water_pack_filled"):
		shoot()
	else:
		$WaterImpactSplash.emitting = false


func shoot() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var direction: float = sign(mouse_pos.x - global_position.x)

	# Prevent player from flipping continuously
	if not Maid.is_within(mouse_pos.x, player.global_position.x - 64, player.global_position.x + 64):
		player.get_node("%Animation").set_direction(direction)
	
	# Ready water pack
	position.x = 50 * direction
	$WaterImpactSplash.rotation = (mouse_pos - global_position).angle()

	if _get_tank_level() <= 0:
		return
	
	var distance := global_position.distance_to(mouse_pos)
	var distance_factor := distance / 500
	
	var damage: float = get_process_delta_time() * damage_per_frame
	_set_tank_level(_get_tank_level() - damage * rate_of_depletion * distance_factor)

	$WaterImpactSplash.emitting = true

	# Spawn water
	var water: RigidBody2D = WATER.instantiate()
	water.damage = damage
	water.top_level = true
	water.global_position = global_position
	
	# Apply randomness to the shot direction based on spray_factor
	var direction_vector = mouse_pos - global_position
	var random_offset = Vector2(
		randf_range(-spray_factor, spray_factor),
		randf_range(-spray_factor, spray_factor)
	) * direction_vector.length()
	
	water.linear_velocity = (direction_vector + random_offset) * projectile_velocity_multiplier
	add_child(water)

	# Push the player back
	player.velocity.x = (global_position.x - mouse_pos.x) * get_process_delta_time() * 10


func refill_tank() -> void:
	var damage: float = get_process_delta_time() * damage_per_frame
	_set_tank_level(min(_get_tank_level() + damage * refill_rate, 100))


func _get_tank_level() -> float:
	return Dialogic.VAR.get_variable("07.tank_level", 0)


func _set_tank_level(new_level: float) -> void:
	Dialogic.VAR.set_variable("07.tank_level", new_level)


func _add_ui() -> void:
	var ui: ProgressBar = UI.instantiate()
	owner.get_node("UI").add_child(ui)


func _on_inventory_updated(item: String, amount: int) -> void:
	if item == "07_water_pack_filled":
		_add_ui()
