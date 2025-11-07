extends StaticBody3D

# === CONFIG ===
var min_angle_deg: float = 0.0
var max_angle_deg: float = 95.0
var door_sensitivity: float = 0.005
var max_nudge_deg: float = 40.0
var min_nudge_distance: float = 0.5
var max_nudge_distance: float = 12.0
var closed_threshold_deg: float = 0.2
var creak_volume: float = -38.0
var min_creak_speed: float = 2.0

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
	var is_moving = angle_diff > (min_creak_speed / 105)

	if is_moving and not audio_creak.playing:
		audio_creak.play()
	#elif not is_moving and audio_creak.playing:
		#print("not moving creak playing")
		#get_tree().create_timer(2)
		#print("2 seconds")
		#audio_creak.stop()

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
	var hinge_pos = hinge.global_transform.origin
	var up = hinge_axis.normalized()

	# Vector from hinge to current door position and hinge to raycast hit
	var door_vec = (global_transform.origin - hinge_pos).normalized()
	var hit_vec = (hit_pos - hinge_pos).normalized()

	# Flatten to the hinge’s rotation plane (remove vertical drift)
	door_vec -= up * door_vec.dot(up)
	hit_vec -= up * hit_vec.dot(up)

	if door_vec.length_squared() == 0 or hit_vec.length_squared() == 0:
		return

	door_vec = door_vec.normalized()
	hit_vec = hit_vec.normalized()

	# Signed angle between door’s current facing and hit direction
	var sin_a = up.dot(door_vec.cross(hit_vec))
	var cos_a = door_vec.dot(hit_vec)
	var target_delta = atan2(sin_a, cos_a)

	# Scale nudge depending on distance (further = stronger)
	var cam_pos = player.get_node("head/Camera3D").global_transform.origin
	var distance = cam_pos.distance_to(hit_pos)
	var nudge_strength = clamp(
		(distance - min_nudge_distance) / (max_nudge_distance - min_nudge_distance),
		0.2, 1.0
	)

	# Apply toward hit direction, respecting facing_invert
	var new_angle = door_angle + target_delta * nudge_strength * facing_invert
	new_angle = clamp(new_angle, deg_to_rad(min_angle_deg), deg_to_rad(max_angle_deg))

	door_angle = new_angle
	_rotate_about_hinge(door_angle)

	print("🎯 Nudge → Δ°:", rad_to_deg(target_delta),
		  "| Strength:", nudge_strength,
		  "| FacingInvert:", facing_invert,
		  "| New Door Angle°:", rad_to_deg(door_angle))
