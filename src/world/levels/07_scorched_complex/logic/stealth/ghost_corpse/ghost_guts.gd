extends RigidBody2D


## Image, weight
@export var guts: Dictionary[Texture2D, float]


func _ready() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	$Sprite2D.texture = guts.keys()[rng.rand_weighted(guts.values())]
	$Sprite2D.offset.y = -$Sprite2D.texture.get_height() / 2
