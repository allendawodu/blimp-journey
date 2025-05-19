extends Node2D

enum State { IDLE, ARM, ACTIVE, COOLDOWN }

@export var knockback: Vector2 = Vector2(512, -1024):
	set(value):
		$KnockbackArea.knockback = value
@export var initial_offset_time: float = 1
@export var arm_time: float = 1
@export var active_time: float = 1
@export var cooldown_time: float = 2

var state: State = State.COOLDOWN

@onready var timer = $Timer


func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	timer.start(initial_offset_time)


func activate() -> void:
	modulate.a = 1
	state = State.ACTIVE
	timer.start(active_time)
	$KnockbackArea.monitoring = true


func cooldown() -> void:
	state = State.COOLDOWN
	timer.start(cooldown_time)
	$KnockbackArea.monitoring = false
	hide()


func arm() -> void:
	state = State.ARM
	timer.start(arm_time)
	modulate.a = 0.5
	show()


func disable() -> void:
	state = State.IDLE


func _on_timer_timeout() -> void:
	match state:
		State.IDLE:
			$KnockbackArea.monitoring = false
			hide()
		State.COOLDOWN:
			arm()
		State.ARM:
			activate()
		State.ACTIVE:
			cooldown()
