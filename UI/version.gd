extends Label

var ProjectVersion := ProjectSettings.get_setting("application/config/version")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ProjectVersion == "":
		text = "Change version in Project Settings"
	else: text = "v"+ProjectVersion


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
