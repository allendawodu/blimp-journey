extends CharacterBody2D

const GHOST = null
const GHOST_FLYING = null

const CORPSE: PackedScene = preload("res://src/world/levels/07_scorched_complex/logic/stealth/ghost_corpse/ghost_guts.tscn")
const GUT_PARTICLES: PackedScene = preload("res://src/world/levels/07_scorched_complex/logic/stealth/ghost_corpse/gut_particles.tscn")

@export var max_speed: float = 800

var _tween: Tween

@onready var health_component: Node = $HealthComponent


func _ready() -> void:
	health_component.damaged.connect(_on_health_component_damaged)


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
