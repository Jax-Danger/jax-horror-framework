extends Node3D
class_name Flashlight
@export var data: ItemData
@onready var light: SpotLight3D = $Light
@onready var collision: CollisionShape3D = $InteractArea/Collision
@onready var flashlight_sound: AudioStreamPlayer3D = $flashlight_sound

var is_on: bool = false
var equipped: bool = false

func interact(player: Node3D):
	if data and data.equippable:
		player.equip_item(self)
	else:
		player.add_to_inventory(self)

func _process(_delta):
	if equipped and Input.is_action_just_pressed("use_item"):
		toggle_light()

func toggle_light():
	is_on = !is_on
	light.visible = is_on
	flashlight_sound.play()
	print("🔦 Flashlight:", ("ON" if is_on else "OFF"))

func on_equipped():
	equipped = true

func on_unequipped():
	equipped = false
	
