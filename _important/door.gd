extends StaticBody3D

enum DoorType { HINGED, TRAPDOOR, SLIDING }
@export var door_type: DoorType = DoorType.HINGED

# === CONFIG ===
var min_angle_deg := 0.0
var max_angle_deg := 95.0
var door_sensitivity := 0.005
var closed_threshold_deg := 0.2

# === AUDIO CONFIG ===
@export var creak_volume := -6.0
@export var close_volume := -25.0
@export var stop_delay := 0.35
@export var movement_threshold := 0.0032

var creak_length := 0.0

# === NODES ===
@onready var hinge: Marker3D = $"../Hinge"
@onready var audio_creak: AudioStreamPlayer3D = $AudioCreak
@onready var audio_close: AudioStreamPlayer3D = $AudioClose
@onready var creak_stream = audio_creak.stream

# === STATE ===
var is_held := false
var door_angle := 0.0
var last_angle := 0.0
var movement_timer := 0.0
var facing_invert := 1
var was_closed := false

var initial_basis
var hinge_axis

@export var audio_delay := 0.25    # seconds before creak system activates
var audio_delay_timer := 0.0
var audio_ready := false


func _ready():
	add_to_group("doors")

	audio_creak.volume_db = creak_volume
	audio_close.volume_db = close_volume

	initial_basis = global_transform.basis
	hinge_axis = hinge.global_transform.basis.y.normalized()

	if creak_stream:
		creak_length = creak_stream.get_length()

	set_process(true)


# ============================================================
#   INPUT ONLY UPDATES THE TARGET ANGLE!
# ============================================================
func _input(event):
	if is_held and event is InputEventMouseMotion:
		var delta = -event.relative.x * door_sensitivity * facing_invert
		door_angle = clamp(
			door_angle + delta,
			deg_to_rad(min_angle_deg),
			deg_to_rad(max_angle_deg)
		)


# ============================================================
#   PROCESS — ALWAYS RUNS, HANDLES ROTATION + AUDIO
# ============================================================
func _process(delta: float) -> void:
	if not is_held:
		audio_delay_timer = 0.0
		audio_ready = false
		if audio_creak.playing:
			audio_creak.stop()
		return

	# always rotate instantly
	_rotate_door(door_angle)

	# count up until allowed to play audio
	if not audio_ready:
		audio_delay_timer += delta
		if audio_delay_timer >= audio_delay:
			audio_ready = true

	# once allowed → run audio logic
	_update_audio(door_angle, delta)
	last_angle = door_angle


func _rotate_door(angle:float):
	# === ROTATION ===
	var hinge_pos = hinge.global_transform.origin
	var door_pos = global_transform.origin

	var offset = door_pos - hinge_pos
	var rot_basis = Basis(hinge_axis, angle)
	var rotated_offset = rot_basis * offset

	var xform = Transform3D()
	xform.origin = hinge_pos + rotated_offset
	xform.basis = rot_basis * initial_basis
	global_transform = xform
	


func _update_audio(angle: float, delta: float) -> void:
	if not audio_ready:
		return  # delay gate not cleared

	var angle_diff = abs(angle - last_angle)
	var moving = angle_diff > movement_threshold

	if moving:
		movement_timer = 0.0

		if not audio_creak.playing:
			audio_creak.play()

		var normalized := inverse_lerp(
			deg_to_rad(min_angle_deg),
			deg_to_rad(max_angle_deg),
			angle
		)
		normalized = clamp(normalized, 0.0, 1.0)
		audio_creak.seek(normalized * creak_length)

	else:
		movement_timer += delta
		if movement_timer >= stop_delay and audio_creak.playing:
			audio_creak.stop()



# ============================================================
#   INTERACTION
# ============================================================
func grab(side):
	is_held = true
	movement_timer = 0.0
	last_angle = door_angle
	if side != 0:
		facing_invert = side

func let_go():
	is_held = false
	audio_creak.stop()
