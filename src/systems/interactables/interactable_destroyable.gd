class_name InteractableDestroyable
extends Interactable

@export_multiline var condition: String
@export_multiline var after_success: String
@export_multiline var after_failure: String


func interact() -> void:
	# CLEANUP
	var result: Variant

	result = true if condition.is_empty() else evaluate_expression(condition)

	if result:
		var expressions: PackedStringArray = after_success.split("\n", false)
		for expression: String in expressions:
			# DEBUG
			# print(expression)
			evaluate_expression(expression)
		target.queue_free()
	else:
		var expressions: PackedStringArray = after_failure.split("\n", false)
		for expression: String in expressions:
			# DEBUG
			# print(expression)
			evaluate_expression(expression)


# NOTE: Expressions cannot evaluate assignment using "=", use get() and set() to achieve that
# NOTE: Add future autoloads to parse and execute below
func evaluate_expression(p_condition: String) -> Variant:
	var e: Expression = Expression.new()
	var error: Error = e.parse(p_condition, ["Inventory", "Dialogic", "EventBus"])
	if error != OK:
		printerr(e.get_error_text())
		return null
	var result: Variant = e.execute([Inventory, Dialogic, EventBus], self)
	if e.has_execute_failed():
		printerr(e.get_error_text())
		return null
	
	return result
