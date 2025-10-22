@tool
extends Node3D

@onready var ray: RayCast3D = $RayCast3D
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var settings:= GameSettings.get_settings()
var step_timer: float = 0.0

func _physics_process(delta: float) -> void:
	step_timer -= delta

	var player: CharacterBody3D = get_parent() as CharacterBody3D
	if not player or not is_instance_valid(player):
		return

	# Stop audio when not walking or airborne
	if audio_player.playing and (not player.is_on_floor() or player.velocity.length() < 0.1):
		audio_player.stop()
		return

	if not player.is_on_floor():
		return

	var sprinting: bool = Input.is_action_pressed("sprint")
	var crouching: bool = Input.is_action_pressed("crouch")
	
	if crouching and sprinting: sprinting = false
	# sprint_cooldown if sprinting crouch_cooldown if crouching else walk_cooldown
	var current_cooldown: float = settings.sprint_cooldown if sprinting else (settings.crouch_cooldown if crouching else settings.walk_cooldown)
	var current_pitch: float = settings.sprint_pitch if sprinting else (settings.crouch_pitch if crouching else settings.walk_pitch)

	if step_timer <= 0.0 and _should_play_step(player):
		_play_footstep(current_pitch)
		step_timer = current_cooldown


func _should_play_step(player: CharacterBody3D) -> bool:
	return player.is_on_floor() and player.velocity.length() > 0.02


func _play_footstep(pitch: float) -> void:
	ray.force_raycast_update()
	if not ray.is_colliding():
		return

	var collider: Object = ray.get_collider()
	if collider == null or not is_instance_valid(collider):
		return
	if collider == get_parent():
		return

	var material_name: String = _detect_material(collider)
	var sound: AudioStream = _get_sound_for_material(material_name)
	if sound:
		audio_player.stop()
		audio_player.stream = sound
		audio_player.pitch_scale = pitch
		audio_player.play()


func _detect_material(collider: Object) -> String:
	if collider.has_meta("surface_type"):
		return str(collider.get_meta("surface_type"))

	if collider is MeshInstance3D:
		var mesh: Mesh = (collider as MeshInstance3D).mesh
		if mesh and mesh.get_surface_count() > 0:
			var mat: Material = mesh.surface_get_material(0)
			if mat:
				return (mat.resource_name if mat.resource_name != "" else mat.resource_path.get_file().get_basename()).to_lower()

	if collider is StaticBody3D:
		for child: Node in (collider as StaticBody3D).get_children():
			if child is MeshInstance3D:
				var mesh2: Mesh = (child as MeshInstance3D).mesh
				if mesh2 and mesh2.get_surface_count() > 0:
					var mat2: Material = mesh2.surface_get_material(0)
					if mat2:
						return (mat2.resource_name if mat2.resource_name != "" else mat2.resource_path.get_file().get_basename()).to_lower()

	return "default"


func _get_sound_for_material(material_name: String) -> AudioStream:
	var data_array: Array = GameSettings.settings.footstep_sounds
	for entry in data_array:
		if entry.material_name.to_lower() == material_name.to_lower():
			return entry.footstep_sound
	for entry in data_array:
		if entry.material_name.to_lower() == "default":
			return entry.footstep_sound
	return null
