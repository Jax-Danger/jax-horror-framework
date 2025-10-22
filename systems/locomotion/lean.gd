extends Node3D

var settings := GameSettings.get_settings()
var lean_angle := settings.lean_angle       # degrees to tilt
var lean_distance := settings.lean_distance    # how far the camera shifts sideways
var lean_speed := settings.lean_speed       # how fast lean happens
var return_speed := settings.return_speed       # slower return feels natural
var target_lean: float = 0.0
var current_lean: float = 0.0
var base_position: Vector3



func _ready() -> void:
	# Store the camera's original local position for reference
	base_position = position

func _process(delta: float) -> void:
	_leaning(delta)
	
func _leaning(delta:float):
	# --- Detect lean input ---
	var input_lean := 0.0
	if Input.is_action_pressed("lean_left"):
		input_lean = -1.0
	elif Input.is_action_pressed("lean_right"):
		input_lean = 1.0

	target_lean = input_lean

	# --- Smooth interpolation ---
	var speed := lean_speed if target_lean != 0 else return_speed
	current_lean = clamp(lerp(current_lean, target_lean, delta * speed), -1.0, 1.0)

	# --- Apply rotation to head (this node) ---
	rotation.z = deg_to_rad(current_lean * -lean_angle)

	# --- Apply position shift to camera (local space) ---
	position.x = base_position.x + (current_lean * lean_distance)
