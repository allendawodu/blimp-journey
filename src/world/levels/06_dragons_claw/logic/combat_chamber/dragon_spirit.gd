extends Line2D

@export var direction: Vector2 = Vector2(1, 0)
@export var speed: float = 1000
@export var length: float = 1024


func _ready() -> void:
	add_to_group("dragon_spirits")
	$LifetimeTimer.timeout.connect(queue_free)

	rotation = direction.angle()


func _process(delta: float) -> void:
	position += direction.normalized() * speed * delta
