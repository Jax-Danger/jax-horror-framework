extends Node3D

@onready var mic_player: AudioStreamPlayer3D = $MicPlayer
@onready var volume_bar: ProgressBar = $MicrophoneLevels/VolumeBar

var mic_enabled: bool = true

func _ready() -> void:
	if not mic_enabled:
		return

	# Setup the microphone stream
	var mic_stream := AudioStreamMicrophone.new()
	mic_player.stream = mic_stream
	mic_player.bus = "Record"  # Send mic to the Record bus
	mic_player.attenuation_filter_cutoff_hz = 0
	mic_player.unit_size = 0.1

	mic_player.play()
	print("🎙️ Microphone active and recording...")

	# Configure the volume bar
	volume_bar.min_value = 0.0
	volume_bar.max_value = 0.8
	volume_bar.value = 0.0

func _process(_delta: float) -> void:
	var mic_bus_idx := AudioServer.get_bus_index("Record")
	if mic_bus_idx == -1:
		return

	var left_db := AudioServer.get_bus_peak_volume_left_db(mic_bus_idx, 0)
	var right_db := AudioServer.get_bus_peak_volume_right_db(mic_bus_idx, 0)
	var avg_db := (left_db + right_db) * 0.5

	# 🔥 Remap dB (-80..0) to visible range (0..1)
	var loudness := inverse_lerp(-38.0, 0.0, avg_db)
	loudness = clamp(loudness, 0.0, 1.0)
	# Smooth UI
	volume_bar.value = lerp(volume_bar.value, loudness, 0.25)
