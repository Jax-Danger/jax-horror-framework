extends CanvasLayer

@onready var crosshair: Label = $Crosshair
@onready var label: Label = $Label

func _ready() -> void:
	crosshair.visible = false
	label.visible = false


func show_prompt(text:String)->void:
	crosshair.visible = true
	label.text = text
	label.visible = true

func hide_prompt()-> void:
	crosshair.visible = false
	label.visible = false
