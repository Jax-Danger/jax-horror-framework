extends VBoxContainer

@onready var title: Label = $HBoxContainer2/VBoxContainer/Title
@onready var sub_title: Label = $HBoxContainer2/VBoxContainer/SubTitle

@export var footer_msg := ""

func _ready() -> void:
	var projectName = ProjectSettings.get_setting("application/config/name")
	var projectDescription = ProjectSettings.get_setting("application/config/description")
	title.text = projectName
	sub_title.text = projectDescription
