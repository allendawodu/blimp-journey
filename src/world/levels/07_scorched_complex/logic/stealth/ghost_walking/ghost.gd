@tool
extends CharacterBody2D

# This is a property that acts like class_name
const GHOST = null
const GHOST_WALKING = null

const CORPSE: PackedScene = preload("res://src/world/levels/07_scorched_complex/logic/stealth/ghost_corpse/ghost_guts.tscn")
const GUT_PARTICLES: PackedScene = preload("res://src/world/levels/07_scorched_complex/logic/stealth/ghost_corpse/gut_particles.tscn")

@export_range(0, 60, 0.5, "or_greater") var walk_time: float = 10:
	set(value):
		walk_time = max(value, 0)
		queue_redraw()

var _tween: Tween

@onready var health_component: Node = $HealthComponent


func _ready() -> void:
	health_component.damaged.connect(_on_health_component_damaged)


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_line(Vector2.ZERO, Vector2.RIGHT * %Roam.speed * walk_time, Color.WHITE)


func turn_around() -> void:
	$StateChart.send_event("wait")


func alert() -> void:
	$StateChart.send_event("pursue")


func kill() -> void:
	var level: Level = get_tree().get_first_node_in_group("level")

	var gut_particles: Node2D = GUT_PARTICLES.instantiate()
	gut_particles.global_position = global_position + Vector2(0, -64)
	gut_particles.emitting = true
	if level:
		level.scene.add_child.call_deferred(gut_particles)

	for i in 10:
		var corpse: RigidBody2D = CORPSE.instantiate()
		corpse.global_position = global_position
		corpse.linear_velocity.x = randf_range(-500, 500)
		if level:
			level.scene.add_child.call_deferred(corpse)
	queue_free()


func _on_health_component_damaged() -> void:
	if _tween and _tween.is_valid():
		return
	var body: CanvasGroup = %Visuals/Body
	_tween = create_tween()
	_tween.tween_property(body, "self_modulate", Color.TRANSPARENT, 0.025)
	_tween.tween_property(body, "self_modulate", Color.WHITE, 0.025)
