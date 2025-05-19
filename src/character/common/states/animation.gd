extends CompoundState

var direction: int = 1

@onready var _target: CharacterBody2D = get_owner()
@onready var _movement: MovementState = %Movement
@onready var _visuals: Node2D = %Visuals
@onready var _animation_player: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	super()

	EventBus.flip_event_started.connect(_on_flip_event)

	$Walk.state_processing.connect(_on_walk_state_processing)
	$Knockback.state_entered.connect(_on_knockback_state_entered)
	$Crouch.state_entered.connect(_override_eye_tracking.bind(Vector2(100, -300)))
	$Crouch.state_exited.connect(%Body.reset_eye_tracking)
	$Fall.state_processing.connect(_on_fall_state_processing)
	$Fall.state_exited.connect(%Body.reset_eye_tracking)
	$Knockback.state_entered.connect(_override_eye_tracking.bind(Vector2(100, 200)))
	$Knockback.state_exited.connect(%Body.reset_eye_tracking)
	$Crouch.state_entered.connect(_on_crouch_state_entered)
	$Crouch.state_exited.connect(_on_crouch_state_exited)


func _on_state_entered() -> void:
	pass


func _on_state_unhandled_input(event: InputEvent) -> void:
	if get_viewport().is_input_handled():
		return


func _on_state_processing(delta: float) -> void:
	if _movement.is_mouse_down:
		direction = roundi(_movement.vector_to_mouse.sign().x)
		
	set_direction(direction)


func _on_state_physics_processing(delta: float) -> void:
	pass


func _on_state_exited() -> void:
	pass


func set_direction(new_direction: int) -> void:
	direction = new_direction
	_visuals.scale.x = direction * absf(_visuals.scale.x)


func _on_walk_state_processing(delta: float) -> void:
	var speed: float = absf(_target.velocity.x)
	
	if speed > 400:
		var blend: float = 1.0 if _animation_player.current_animation == "walk" else 0.1667
		_animation_player.play("run", blend, remap(speed, 400, 1024, 0.8, 1))
	else:
		_animation_player.play("walk", 0.3, remap(speed, 0, 400, 0.95, 1.2))


func _on_knockback_state_entered() -> void:
	# CLEANUP
	if _target is Player:
		const EXCLAMATION: PackedScene = preload("res://src/character/player/exclamation/exclamation.tscn")
		var exclamation: Exclamation = EXCLAMATION.instantiate()
		exclamation.global_position = _target.global_position
		exclamation.top_level = true
		_target.add_child(exclamation)

		var shake_addon: PCamShake = get_tree().get_first_node_in_group("procam").addons[1]
		shake_addon.shake()


func _on_fall_state_processing(delta: float) -> void:
	var target_position: Vector2 = _target.global_position + Vector2(32, 0)
	%Body.override_eye_tracking(_target.get_global_mouse_position()\
			.lerp(target_position, minf(_animation_player.current_animation_position / 0.2, 1)))


func _on_crouch_state_entered() -> void:
	_target.get_node("CrouchCollisionShape").disabled = false
	_target.get_node("CollisionShape2D").disabled = true


func _on_crouch_state_exited() -> void:
	_target.get_node("CollisionShape2D").disabled = false
	_target.get_node("CrouchCollisionShape").disabled = true


func _override_eye_tracking(position_relative_to_character: Vector2) -> void:
	%Body.override_eye_tracking(_target.global_position + position_relative_to_character)


func _on_flip_event(args: Dictionary) -> void:
	if args.who == _target.name.to_snake_case():
		set_direction(args.direction)

		# TODO: Eventually, this will be replaced with an animation
		await get_tree().create_timer(0.25).timeout

		EventBus.flip_event_ended.emit(args.uuid)
