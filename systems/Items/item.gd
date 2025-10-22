extends Node3D
class_name Item

@export var data: ItemData
var equipped := false
var player_ref: Node3D = null

func _ready():
	if data == null:
		push_warning("⚠️ No ItemData resource assigned!")

func interact(player: Node3D):
	if data.equippable:
		player.equip_item(self)
	else:
		player.add_to_inventory(self)

# Called when the player equips it
func on_equipped():
	equipped = true
	_set_collisions_enabled(false)

# Called when the player drops or unequips it (optional for later)
func on_unequipped():
	equipped = false
	_set_collisions_enabled(true)

func _set_collisions_enabled(enabled: bool):
	for child in get_children():
		if child is CollisionShape3D:
			child.disabled = not enabled
		elif child is CollisionObject3D:
			child.disabled = not enabled
		elif child.get_child_count() > 0:
			for sub in child.get_children():
				if sub is CollisionShape3D:
					sub.disabled = not enabled
