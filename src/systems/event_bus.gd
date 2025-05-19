extends Node

# Interactions
signal interactable_mouse_entered(other: Interactable)
signal interactable_mouse_exited(other: Interactable)
signal pathfind_started(to: Interactable)
## It's possible for `to` to be null. Shouldn't cause a problem though.
signal pathfind_aborted(to: Interactable)
## args = {type: Behavior.Type, who: String, index: int}.
signal behavior_event_started(args: Dictionary)
signal behavior_event_ended(uuid: String)
## args = {animation: Animations, who: String, repeat: int}.
signal emote_event_started(args: Dictionary)
## args = {who: String, direction: int}.
signal flip_event_started(args: Dictionary)
signal flip_event_ended(uuid: String)
signal item_examine_started(item: String)

# Pausing
signal about_to_pause(initiator: String)
signal about_to_resume(initiator: String)

# Overworld Map
signal clouds_cleared(region: int)

# Saving and loading
signal save_completed
signal event_completed(event: String)
signal event_list_updated(events: Array[String])

# Camera
signal camera_event_started(cinematic_id: Variant, index: int)
signal camera_event_ended
