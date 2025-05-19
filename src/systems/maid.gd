extends Node
## Utils.


## Checks if a value is within `start` and `end`.
func is_within(value: Variant, start: Variant, end: Variant, is_inclusive: bool = false) -> bool:
	assert(typeof(value) == typeof(start) and typeof(value) == typeof(end), "Types need to be the same.")
	if is_inclusive:
		return value >= start and value <= end
	else:
		return value >= start and value < end


## Checks if the `InputEvent` is a left click.
func is_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
