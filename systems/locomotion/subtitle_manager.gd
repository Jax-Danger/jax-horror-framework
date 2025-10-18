extends CanvasLayer
class_name SubtitleManager

@onready var label: Label = $Label

var queue: Array = []
var is_playing: bool = false
var fade_time: float = 0.25

func _ready(): label.text = ""

func show_subtitles(text: String, duration: float) -> void:
	queue.append({ "text": text, "duration": duration })
	if not is_playing:
		_process_queue()


func _process_queue() -> void:
	is_playing = true

	while queue.size() > 0:
		var entry = queue.pop_front()
		await _play_subtitle(entry["text"], entry["duration"])
		await get_tree().create_timer(0.1).timeout  # small pause before next

	is_playing = false


func _play_subtitle(text: String, duration: float) -> void:
	label.text = text
	label.show()
	label.modulate.a = 0.0

	# Fade in
	var tween_in = create_tween()
	tween_in.tween_property(label, "modulate:a", 1.0, fade_time)
	await tween_in.finished

	# Display for (duration - fade times), but never less than a tiny delay
	var visible_time = max(duration - fade_time * 2.0, 0.05)
	await get_tree().create_timer(visible_time).timeout

	# Fade out
	var tween_out = create_tween()
	tween_out.tween_property(label, "modulate:a", 0.0, fade_time)
	await tween_out.finished

	label.hide()
