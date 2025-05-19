extends RigidBody2D

var _player: Player

@onready var initial_position: Vector2 = global_position


func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if is_instance_valid(_player) and _player.is_on_floor():
		_player = null
		explode()


func _physics_process(delta: float) -> void:
	if not freeze:
		global_position.x = initial_position.x


func explode() -> void:
	SaverLoader.complete_event("04_escape_sequence_finished")

	await get_tree().create_timer(1).timeout

	freeze = false
	linear_velocity = Vector2(0, -4096)

	await get_tree().create_timer(2).timeout

	EventBus.about_to_pause.emit()
	get_tree().change_scene_to_file("res://src/ui/account_management/authentication/authenticate.tscn")


func _on_body_entered(other: Node2D) -> void:
	if other is Player:
		_player = other as Player


func _on_body_exited(other: Node2D) -> void:
	if other is Player:
		_player = null
