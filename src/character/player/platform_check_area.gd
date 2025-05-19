class_name PlatformChecker
extends Area2D

## Platform collision bit (2) + 1.
@export var platform_mask: int = 3

var is_on_platform: bool
var num_platforms: int:
	set(value):
		num_platforms = value
		is_on_platform = num_platforms > 0

@onready var _target: CharacterBody2D = get_owner()
@onready var _drop_timer: Timer = $DropTimer


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	_drop_timer.timeout.connect(_on_drop_timer_timeout)


## Drop the character through the platform.
func drop() -> void:
	_target.set_collision_mask_value(platform_mask, false)
	_drop_timer.start()


func _on_body_entered(other: Node2D) -> void:
	if _is_on_platform(other):
		num_platforms += 1


func _on_body_exited(other: Node2D) -> void:
	if _is_on_platform(other):
		num_platforms -= 1


func _on_drop_timer_timeout() -> void:
	_target.set_collision_mask_value(platform_mask, true)


func _is_on_platform(other: Node2D) -> bool:
	return (other.has_method("get_collision_layer_value") and other.get_collision_layer_value(platform_mask)) \
		or (other is TileMapLayer and other.tile_set.get_physics_layer_collision_layer(0) == roundi(pow(2, platform_mask - 1)))  # Weird calculation converts bit to value
