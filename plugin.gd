@tool
extends EditorPlugin

var _autoloads := [
	{"name": "EventBus", "path": "res://addons/jax-horror-framework/autoloads/event_bus.gd" },
	{"name": "GameSettings", "path": "res://addons/jax-horror-framework/autoloads/game_settings.gd"},
	{"name": "SaveSystem", "path": "res://addons/jax-horror-framework/autoloads/save_system.gd"},
]

func _enter_tree() -> void:
	# Register autoloads
	for a in _autoloads:
		if not ProjectSettings.has_setting("autoload/%s" % a.name):
			add_autoload_singleton(a["name"], a["path"])

func _exit_tree() -> void:
	remove_custom_type("HorrorLevel")
