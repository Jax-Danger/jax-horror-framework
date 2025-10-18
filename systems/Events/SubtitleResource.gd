extends Resource
class_name Subtitles

@export var play_once: bool = true
@export var delay : float = 0.5
@export_multiline var sub_title: String

# Voice playback
@export var has_voice: bool = false
@export var is_speaker: bool = false
@export_file("*.mp3", "*.wav", "*.ogg") var player_voice_file: String
@export_node_path("AudioStreamPlayer3D") var speaker_node_path: NodePath

func _get_property_list() -> Array:
	var props = []

	props.append({ "name": "play_once", "type": TYPE_BOOL, "usage": PROPERTY_USAGE_DEFAULT })
	props.append({ "name": "delay", "type": TYPE_FLOAT, "usage": PROPERTY_USAGE_DEFAULT })
	props.append({ "name": "sub_title", "type": TYPE_STRING, "hint": PROPERTY_HINT_MULTILINE_TEXT, "usage": PROPERTY_USAGE_DEFAULT })
	props.append({ "name": "has_voice", "type": TYPE_BOOL, "usage": PROPERTY_USAGE_DEFAULT })

	if has_voice:
		props.append({ "name": "is_speaker", "type": TYPE_BOOL, "usage": PROPERTY_USAGE_DEFAULT })
		if is_speaker:
			props.append({ "name": "speaker_node_path", "type": TYPE_NODE_PATH, "usage": PROPERTY_USAGE_DEFAULT })
		else:
			props.append({ "name": "player_voice_file", "type": TYPE_STRING, "hint": PROPERTY_HINT_FILE, "hint_string": "*.mp3,*.wav,*.ogg", "usage": PROPERTY_USAGE_DEFAULT })

	return props
