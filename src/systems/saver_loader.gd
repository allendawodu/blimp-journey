extends Node

const COLLECTION_ID: String = "saves"
const DEFAULTS: Dictionary = {
	"metadata": {
		"version": 0,
	},
	"stats": {
		"playtime": 0,
		"times_opened": 0,
		"first_opened": -1,
		"last_opened": -1,
	},
	"player": {
		"first_name": "",
		"last_name": "",
		"username": "",
		"billing": {
			"membership_status": "",
			"stripe_customer_id": "",
		},
		"appearance": {},
		"tags": [],  # For A/B testing, etc.
	},
	"levels": {
		"current_level": "",
	},
}

## Hold data that doesn't need to be saved permanently.
var temp: Dictionary
## Latest save file retrieved from the server.
## May be outdated, so prefer calling [method SaverLoader.load_game] to get the latest data.
var latest_document: FirestoreDocument

var _save_file_updaters: Array[Callable] = [
	# _v0_to_v1,
]


func _ready() -> void:
	add_to_group("persist")


func save_game() -> void:
	# Retrieve the save data
	var document: FirestoreDocument = await _get_document()

	if document == null:
		return
	
	latest_document = document

	# Get data from persistable entities
	for entity: Node in get_tree().get_nodes_in_group("persist"):
		if not entity.has_method("save_data"):
			printerr(entity, " does not have save method despite being in persist group.")
			continue
		
		entity.save_data(document)
	
	# Upload the save data
	var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
	await collection.update(document)

	print("Save successful.")
	EventBus.save_completed.emit()


func load_game() -> void:
	# Retrieve the save data on the server
	var document: FirestoreDocument = await _get_document()

	if document == null:
		return

	# Check version and update if outdated
	var current_version: int = document.get_field("metadata.version", -1)
	
	if current_version == -1:
		push_error("[SaverLoader] This save file doesn't have a `version` property. Aborting...")
		return

	for version: int in range(current_version, _save_file_updaters.size()):
		var updating_document: Variant = _save_file_updaters[version].call(document.copy())

		if updating_document == null:
			push_error("[SaverLoader] Updated from v%d to v%d. Aborting save file update..." % [current_version, document.get_field("metadata.version", -1)])
			break
	
		document = updating_document

		print("[SaverLoader] Updated from v%d to v%d." % [current_version, document.get_field("metadata.version", -1)])
	
	latest_document = document

	# Load data into entities
	for entity: Node in get_tree().get_nodes_in_group("persist"):
		if not entity.has_method("load_data"):
			printerr(entity, " does not have load method despite being in persist group.")
			continue

		entity.load_data(document)
	
	print("Load successful.")


func reset_level(level_code: int) -> void:
	# Retrieve the save data on the server
	var document: FirestoreDocument = await _get_document()

	if document == null:
		return
	
	document.remove_field("levels.%02d" % level_code)
	document.set_field("levels.current_level", "")

	Inventory.clear()

	# Upload the save data
	var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
	await collection.update(document)

	print("Level %02d reset." % level_code)


func reset_save_game() -> void:
	if not Firebase.Auth.is_logged_in():
		printerr("[SaverLoader] User is not authenticated. Aborting...")
		return
		
	var auth: Dictionary = Firebase.Auth.auth
	var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
	
	# NOTE: The following line is expected to throw a GET error, ignore it
	# There is no "has_doc" to check if a doc exists 
	var document: FirestoreDocument = await collection.get_doc(auth.localid)
	
	if document:
		await collection.delete(document)
	
	await collection.add(auth.localid, DEFAULTS)


func complete_event(event: String) -> void:
	if not EventBus.event_list_updated.is_connected(save_game):
		EventBus.event_list_updated.connect(save_game.unbind(1))

	EventBus.event_completed.emit(event)


func save_data(document: FirestoreDocument) -> void:
	document.set_field("metadata.version", DEFAULTS.metadata.version)


func load_data(document: FirestoreDocument) -> void:
	pass


## Helper method to get the document from the server
## Returns null if there's an error or the user is not authenticated
func _get_document() -> FirestoreDocument:
	var auth: Dictionary = Firebase.Auth.auth

	if not Firebase.Auth.is_logged_in():
		printerr("[SaverLoader] User is not authenticated. Aborting...")
		return null
	
	var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
	var document: FirestoreDocument = await collection.get_doc(auth.localid)
	
	if document == null:
		printerr("[SaverLoader] Cannot retrieve save file from server. Aborting...")
		return null
		
	return document


#region Save File Updaters

## If null is returned, an error has occured.
## Don't forget to update the version number in the metadata.
func _v0_to_v1(document: FirestoreDocument) -> Variant:
	document.set_field("metadata.version", 1)
	return document

#endregion
