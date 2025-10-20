extends Node3D
class_name DoorInteractive

@export var open_axis: Vector3 = Vector3.UP
@export var min_angle: float = -90.0
@export var max_angle: float = 90.0
@export var sensitivity: float = 0.3

var _is_grabbed := false
var _current_angle: float = 0.0
var _open_direction: float = 1.0
var _player_ref: Node = null

func interact(player: Node) -> void:
	_is_grabbed = true
	_player_ref = player

	# Compute player's side relative to hinge plane
	var door_pos: Vector3 = global_transform.origin
	var player_pos: Vector3 = player.global_transform.origin

	# Door's local "right" direction (the side opposite the hinge)
	var right_dir: Vector3 = global_transform.basis.x.normalized()
	var to_player: Vector3 = (player_pos - door_pos).normalized()

	# Dot product decides which side player is on
	var side := right_dir.dot(to_player)
	_open_direction = 1.0 if side >= 0.0 else -1.0
	# Players on one side push, on the other pull

func stop_interacting() -> void:
	_is_grabbed = false
	_player_ref = null

func _input(event: InputEvent) -> void:
	if not _is_grabbed:
		return

	if event is InputEventMouseMotion:
		var delta :float= event.relative.x * sensitivity * _open_direction
		_current_angle = clamp(_current_angle + delta, min_angle, max_angle)
		rotation = open_axis * deg_to_rad(_current_angle)

	elif event.is_action_released("interact"):
		stop_interacting()
