## @meta-authors Kyle Szklenski
## @meta-version 2.2
## A reference to a Firestore Document.
## Documentation TODO.
@tool
class_name FirestoreDocument
extends Node

# Signals
signal changed(changes)

# Variables
var document: Dictionary # The Document itself
var doc_name: String # Only .name
var create_time: String # createTime
var collection_name: String # Name of the collection to which it belongs
var _transforms: FieldTransformArray # The transforms to apply
var field_added_or_updated: bool # true or false if anything has been added or updated since the last update()

# Initialization
func _init(doc: Dictionary = {}):
	_transforms = FieldTransformArray.new()
	
	if doc.has("fields"):
		document = doc.fields
	if doc.has("name"):
		doc_name = doc.name
		if doc_name.count("/") > 2:
			doc_name = (doc_name.split("/") as Array).back()
	if doc.has("createTime"):
		self.create_time = doc.createTime

# Public Methods
func replace(with: FirestoreDocument, is_listener := false) -> void:
	var current = document.duplicate()
	document = with.document
	
	var changes = {"added": [], "removed": [], "updated": [], "is_listener": is_listener}
	
	for key in current.keys():
		if not document.has(key):
			changes.removed.push_back({"key": key})
		else:
			var new_value = Utilities.from_firebase_type(document[key])
			var old_value = Utilities.from_firebase_type(current[key])
			if typeof(new_value) != typeof(old_value) or new_value != old_value:
				if old_value == null:
					changes.removed.push_back({"key": key}) # ??
				else:
					changes.updated.push_back({"key": key, "old": old_value, "new": new_value})
	
	for key in document.keys():
		if not current.has(key):
			changes.added.push_back({"key": key, "new": Utilities.from_firebase_type(document[key])})
	
	if not (changes.added.is_empty() and changes.removed.is_empty() and changes.updated.is_empty()):
		changed.emit(changes)

func new_document(base_document: Dictionary) -> void:
	var current = document.duplicate()
	document = {}
	for key in base_document.keys():
		document[key] = Utilities.to_firebase_type(key)
	
	var changes = {"added": [], "removed": [], "updated": [], "is_listener": false}
	
	for key in current.keys():
		if not document.has(key):
			changes.removed.push_back({"key": key})
		else:
			var new_value = Utilities.from_firebase_type(document[key])
			var old_value = Utilities.from_firebase_type(current[key])
			if typeof(new_value) != typeof(old_value) or new_value != old_value:
				if old_value == null:
					changes.removed.push_back({"key": key}) # ??
				else:
					changes.updated.push_back({"key": key, "old": old_value, "new": new_value})
	
	for key in document.keys():
		if not current.has(key):
			changes.added.push_back({"key": key, "new": Utilities.from_firebase_type(document[key])})
	
	if not (changes.added.is_empty() and changes.removed.is_empty() and changes.updated.is_empty()):
		changed.emit(changes)

func is_null_value(key) -> bool:
	return document.has(key) and Utilities.from_firebase_type(document[key]) == null

func add_field_transform(transform: FieldTransform) -> void:
	_transforms.push_back(transform)

func remove_field_transform(transform: FieldTransform) -> void:
	_transforms.erase(transform)
	
func clear_field_transforms() -> void:
	_transforms.transforms.clear()
		
func _erase(field_path: String) -> void:
	document.erase(field_path)

## Add or update a specified field.
## Supports dot notation.
func set_field(field_path: String, value: Variant) -> void:
	var changes = {"added": [], "removed": [], "updated": [], "is_listener": false}
	var existing_value = get_field(field_path)
	_manipulate_field(field_path, _set_value_action.bind(value))
	var has_field_path = existing_value != null and not is_null_value(field_path)

	if has_field_path:
		changes.updated.push_back({"key": field_path, "old": existing_value, "new": value})
	else:
		changes.added.push_back({"key": field_path, "new": value})

	field_added_or_updated = true
	changed.emit(changes)

## Get value from a specified field or default if it doesn't exist.
## Supports dot notation.
func get_field(field_path: String, default: Variant = null) -> Variant:
	if field_path == "doc_name":
		return doc_name
	elif field_path == "collection_name":
		return collection_name
	elif field_path == "create_time":
		return create_time

	var result = _manipulate_field(field_path, _get_value_action)
	if result != null:
		return Utilities.from_firebase_type(result)
	return default

## Remove specified field or do nothing if field does not exist.
## Supports dot notation.
func remove_field(field_path: String) -> void:
	var changes = {"added": [], "removed": [], "updated": [], "is_listener": false}
	_manipulate_field(field_path, _remove_value_action)
	changes.removed.push_back({"key": field_path})
	changed.emit(changes)


## Return a copy of this document.
func copy() -> FirestoreDocument:
	var result = FirestoreDocument.new()
	result.collection_name = collection_name
	result.doc_name = doc_name
	result.create_time = create_time
	result.document = document.duplicate(true)
	return result


func on_snapshot(when_called: Callable, poll_time: float = 1.0) -> FirestoreListener.FirestoreListenerConnection:
	if get_child_count() >= 1: # Only one listener per document
		assert(false, "Multiple listeners not allowed for the same document yet")
		return
	
	changed.connect(when_called, CONNECT_REFERENCE_COUNTED)
	var listener = load("res://addons/godot-firebase/firestore/firestore_listener.tscn").instantiate()
	add_child(listener)
	listener.initialize_listener(collection_name, doc_name, poll_time)
	listener.owner = self
	var result = listener.enable_connection()
	return result

func has_changes_pending() -> bool:
	return field_added_or_updated

func get_unsafe_document() -> Dictionary:
	var result = {}
	for key in keys():
		result[key] = Utilities.from_firebase_type(document[key])
	return result
	
func keys():
	return document.keys()

# Overrides
func _to_string() -> String:
	return ("doc_name: {doc_name}, \ndata: {data}, \ncreate_time: {create_time}\n").format(
		{doc_name = self.doc_name, data = document, create_time = self.create_time})

# Helpers
func _manipulate_field(field_path: String, action: Callable) -> Variant:
	var keys = Array(field_path.split("."))
	var current_dict = document
	var last_key = keys.pop_back()

	for key in keys:
		if not current_dict.has(key) or typeof(current_dict[key]) != TYPE_DICTIONARY:
			current_dict[key] = {"mapValue": {"fields": {}}}
		if not current_dict[key].has("mapValue") or not current_dict[key]["mapValue"].has("fields"):
			current_dict[key]["mapValue"] = {"fields": {}}
		current_dict = current_dict[key]["mapValue"]["fields"]

	return action.call(current_dict, last_key)

func _set_value_action(current_dict: Dictionary, last_key: String, value: Variant) -> Variant:
	current_dict[last_key] = Utilities.to_firebase_type(value)
	return value

func _get_value_action(current_dict: Dictionary, last_key: String) -> Variant:
	if current_dict.has(last_key):
		return current_dict[last_key]
	return null

func _remove_value_action(current_dict: Dictionary, last_key: String) -> void:
	if current_dict.has(last_key):
		current_dict.erase(last_key)

func _get(property: StringName) -> Variant:
	return get_field(property)

func _set(property: StringName, value: Variant) -> bool:
	assert(value != null, "When using the dictionary setter, the value cannot be null; use erase_field instead.")
	document[property] = Utilities.to_firebase_type(value)
	return true
