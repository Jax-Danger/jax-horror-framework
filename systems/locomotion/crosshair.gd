extends CanvasLayer

@onready var crosshair: Label = $Crosshair

func _ready() -> void:
	crosshair.visible = false


func show_prompt(text:String)->void:
	crosshair.visible = true

func hide_prompt()-> void:
	crosshair.visible = false
