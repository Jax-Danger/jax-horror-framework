extends Node

signal settings_changed
var settings: SettingsResource
const DEFAULT_SETTINGS_PATH := "res://default_settings.tres"

func _ready(): _load_settings()
func reload_settings(): _load_settings()

func get_settings() -> SettingsResource:
	if not settings:
		var resource = load(DEFAULT_SETTINGS_PATH)
		if resource:
			settings = resource as SettingsResource
		else:
			push_error("Failed to load deafult settings at " + DEFAULT_SETTINGS_PATH)
	return settings

func get_normalized_sensitivity() -> float:
	return pow(settings.mouse_sensitivity / 100.0, 2.0)

func _load_settings():
	if not settings:
		var loaded = load(DEFAULT_SETTINGS_PATH)
		if loaded:
			settings = loaded as SettingsResource
		else:
			push_error("⚠️ Failed to load default settings at " + DEFAULT_SETTINGS_PATH)

func save_settings():
	if not settings:
		push_error("[GameSettings] Cannot save - settings resource is null")
		return
	
	var result = ResourceSaver.save(settings, DEFAULT_SETTINGS_PATH)
	if result == OK:
		print("[GameSettings] Settings save successfully to:", DEFAULT_SETTINGS_PATH)
		emit_signal("settings_changed")
	else:
		push_error("[GameSettings] Failed to save settings to: %s" % DEFAULT_SETTINGS_PATH)
