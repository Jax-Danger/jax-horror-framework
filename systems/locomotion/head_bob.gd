extends "res://addons/jax-horror-framework/systems/locomotion/lean.gd"

var bob_frequency_walk := settings.bob_frequency_walk
var bob_frequency_run := settings.bob_frequency_run
var bob_amplitude_walk := settings.bob_amplitude_walk
var bob_amplitude_run := settings.bob_amplitude_run
var smooth := settings.smooth

var bob_timer := 0.0
var original_position := Vector3.ZERO
var player : CharacterBody3D


func _ready():
	super._ready()
	original_position = position
	player = get_parent()

func _process(delta: float) -> void:
	super._process(delta)
	if not player:
		return

	var speed := player.velocity.length()
	var is_grounded := player.is_on_floor()
	
	if speed > 0.1 and is_grounded:
		var sprinting := Input.is_action_pressed("sprint")
		var frequency := lerp(bob_frequency_walk, bob_frequency_run, float(sprinting))
		var amplitude := lerp(bob_amplitude_walk, bob_amplitude_run, float(sprinting))

		bob_timer += delta * frequency
		var offset_y = sin(bob_timer * 2.0) * amplitude
		var offset_x = sin(bob_timer) * amplitude * 0.5
		
		var target_position = original_position + Vector3(offset_x, offset_y, 0)
		position = position.lerp(target_position, delta * smooth)
	else:
		# Reset back to neutral position
		position = position.lerp(original_position, delta * smooth)
		bob_timer = 0.0
