extends Resource
class_name LevelEvent


## The name of this event (used for identification or debugging).
@export var event_name: String = "Unnamed Event"
## The Area3D node in the scene that triggers this event.
@export_node_path("Area3D") var trigger_path: NodePath
## The name of the signal on the trigger node to connect to.
@export var signal_name: String = "body_entered"
## Optional: only trigger when this group enters (leave empty to allow any body)
@export var require_group: String = "player"
## Add subtitles if you want to.
@export var subtitles: Array[Subtitles]

@export var actions: Array[EventActions]
