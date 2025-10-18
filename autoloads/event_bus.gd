extends Node3D

var _played_subtitles: Dictionary = {}
## Events for your horror level that trigger specifically on collision with an Area3D node.
@export var events: Array[LevelEvent] = []
var has_interacted = false

func _ready() -> void:
	for e in events:
		_register_event(e)

func _register_event(e: LevelEvent) -> void:
	if e.trigger_path.is_empty():
		push_warning("Skipping event '%s': no trigger path." % e.event_name)
		return

	var trigger := get_node_or_null(e.trigger_path)
	if trigger == null or !(trigger is Area3D):
		push_warning("Trigger is missing or not an Area3D for: %s" % e.event_name)
		return

	var sig := e.signal_name if e.signal_name != "" else "body_entered"
	if not trigger.has_signal(sig):
		push_warning("Signal '%s' not found on %s" % [sig, trigger.name])
		return

	# Connect event
	if not trigger.is_connected(sig, Callable(self, "_on_trigger_fired")):
		trigger.connect(sig, Callable(self, "_on_trigger_fired").bind(e))
		print("[LevelEvents] Connected %s.%s (%s)" % [trigger.name, sig, e.event_name])

func _on_trigger_fired(arg: Variant, e: LevelEvent) -> void:
	if e.require_group != "":
		if arg is Node and not arg.is_in_group(e.require_group):
			return

	for action in e.actions:
		_execute_action(arg, e, action)

	# Handle subtitles after
	if e.subtitles.size() > 0:
		var player := (arg as Node) if arg is Node else null
		if player:
			await _play_subtitles(e.subtitles, player)

func _execute_action(arg: Variant, e: LevelEvent, action: EventActions) -> void:
	var delay: float = action.get("delay")
	var target_path: NodePath = action.get("target_path")
	var target_method: String = action.get("target_method")
	var args: Array = action.get("arguments")
	var is_interactable: bool = action.get("is_interactable")
	if target_path == NodePath("") or target_method == "":
		return

	var target = get_node_or_null(target_path)
	if target == null or not target.has_method(target_method):
		push_warning("Invalid target for event: %s" % e.event_name)
		return

	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	
	_call_method_safely(target, target_method, args)

func _call_method_safely(target: Node, method_name: String, args: Array):
	var expected_args := target.get_method_argument_count(method_name)

	# Basic sanity check
	if expected_args == 0:
		target.callv(method_name, [])
		return

	# Convert incompatible argument types if necessary
	for i in range(min(args.size(), expected_args)):
		if args[i] is Object and expected_args > 0:
			# Automatically convert collider (Object) to name or string if method expects a String
			args[i] = str(args[i].name) if args[i].has_method("get_name") else str(args[i])

	# Trim or pad arguments to expected count
	while args.size() > expected_args:
		args.pop_back()
	while args.size() < expected_args:
		args.append(null)

	# Safe call
	var result = target.callv(method_name, args)
	return result

func _play_subtitles(subtitles: Array[Subtitles], player: Node) -> void:
	if subtitles.is_empty():
		return

	var subtitle_manager := player.get_node_or_null("SubtitleManager")
	if subtitle_manager == null:
		push_warning("SubtitleManager not found on player.")
		return
	
	for s in subtitles:
		if not (s is Subtitles):
			continue
		
		var key := s.resource_path if s.resource_path != "" else s.sub_title.strip_edges()
		if s.play_once and _played_subtitles.has(key):
			continue
		if s.play_once:
			_played_subtitles[key] = true
		
		subtitle_manager.show_subtitles(s.sub_title, s.delay)
		
		if s.has_voice:
			print("Has voice.")
			var speaker := get_node_or_null(s.speaker_node_path)
			if speaker and speaker is AudioStreamPlayer3D:
				print("it's a speaker!")
				speaker.play()
			elif s.player_voice_file != "":
				var voice_player := player.get_node_or_null("Head/VoicePlayer")
				if voice_player and voice_player is AudioStreamPlayer3D:
					voice_player.stream  = load(s.player_voice_file)
					voice_player.play()
					print("loaded voice player.")
		await get_tree().create_timer(s.delay + 0.25).timeout
