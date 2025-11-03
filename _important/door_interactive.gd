extends StaticBody3D
class_name DoorInteractive


# === CONFIG ===
@export var min_angle_deg: float = 0.0
@export var max_angle_deg: float = 95.0
@export var door_sensitivity: float = 0.01
@export var max_nudge_deg: float = 40.0
@export var min_nudge_distance: float = 0.5
@export var max_nudge_distance: float = 2.0
@export var closed_threshold_deg: float = 5.0
@export var creak_volume: float = -30.0
@export var min_creak_speed: float = 0.008

# === NODES ===
@onready var hinge: Marker3D = $"../Hinge"
@onready var audio_creak: AudioStreamPlayer3D = $AudioCreak
@onready var audio_close: AudioStreamPlayer3D = $AudioClose

# === STATE ===
var player: Node3D
var is_held := false
var door_angle := 0.0
var last_angle := 0.0
var facing_invert := 1
var was_closed := false
var initial_basis: Basis
var hinge_axis: Vector3


func _ready() -> void:
	add_to_group("doors")
	audio_creak.volume_db = creak_volume
	audio_close.volume_db = -20

	# store initial transform reference
	initial_basis = global_transform.basis
	hinge_axis = hinge.global_transform.basis.y.normalized()


# === INPUT ===
func _input(event: InputEvent) -> void:
	if is_held and event is InputEventMouseMotion:
		var delta = -event.relative.x * door_sensitivity * facing_invert
		door_angle = clamp(
			door_angle + delta,
			deg_to_rad(min_angle_deg),
			deg_to_rad(max_angle_deg)
		)
		_rotate_about_hinge(door_angle)


# === ROTATION AROUND HINGE AXIS ===
func _rotate_about_hinge(angle: float) -> void:
	var hinge_pos = hinge.global_transform.origin
	var door_pos = global_transform.origin

	# direction from hinge to door
	var offset = door_pos - hinge_pos

	# rotation in world space using hinge's current axis
	var rot_basis = Basis(hinge_axis, angle)
	var rotated_offset = rot_basis * offset

	# apply new transform
	var xform = Transform3D()
	xform.origin = hinge_pos + rotated_offset
	xform.basis = rot_basis * initial_basis
	global_transform = xform

	# --- AUDIO ---
	var angle_diff = abs(angle - last_angle)
	var is_moving = angle_diff > min_creak_speed

	if is_moving and not audio_creak.playing:
		audio_creak.play()
	elif not is_moving and audio_creak.playing:
		audio_creak.stop()

	if abs(rad_to_deg(angle) - min_angle_deg) <= closed_threshold_deg:
		if not was_closed:
			audio_close.play()
			was_closed = true
	else:
		was_closed = false

	last_angle = angle


# === INTERACTION ===
func grab(p: Node3D, hit_pos: Vector3, side: int) -> void:
	player = p
	is_held = true
	if side != 0:
		facing_invert = side
	_apply_nudge(hit_pos)


func let_go() -> void:
	is_held = false
	audio_creak.stop()


# === NUDGE ===
func _apply_nudge(hit_pos: Vector3) -> void:
	var cam_pos = player.get_node("head/Camera3D").global_transform.origin
	var distance = cam_pos.distance_to(hit_pos)
	var nudge_strength = clamp(
		(distance - min_nudge_distance) / (max_nudge_distance - min_nudge_distance),
		0.0, 1.0
	)

	var nudge_deg = lerp(0.0, max_nudge_deg, nudge_strength)
	var current_deg = rad_to_deg(door_angle)
	var nudge_dir = facing_invert
	var target = clamp(
		deg_to_rad(current_deg + nudge_deg * nudge_dir),
		deg_to_rad(min_angle_deg),
		deg_to_rad(max_angle_deg)
	)
	door_angle = target
	_rotate_about_hinge(target)
