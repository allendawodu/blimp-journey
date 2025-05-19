class_name Tile04
extends Button

const DISABLED_COLOR: Color = Color(0.5, 0.5, 0.5)

var match_number: int
var texture: Texture:
	set(value):
		$TextureRect.texture = value


func disable() -> void:
	disabled = true
	modulate = DISABLED_COLOR
