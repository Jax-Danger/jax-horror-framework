extends Node
class_name GameController

static var _instance: GameController

@export var player_scene: PackedScene
@onready var world_3d: Node3D = $World3D
@onready var gui_root: Control = $GUI
@onready var pause_menu: Control = $GUI/PauseMenu

var current_scene: Node = null
var current_scene_path: String = ""
var player: Node3D = null
var is_loading: bool = false

enum GameState { RUNNING, PAUSED }
var game_state: GameState = GameState.RUNNING
signal game_state_changed(state: GameState)
signal scene_loaded(scene_path: String)
signal scene_unloaded(scene_path: String)
signal scene_changed(old_path: String, new_path: String)

func _ready() -> void:
	_instance = self
	
	print("[GameController] Scene ready.")
	if GameSettings.settings.Starting_Level != null:
		change_scene_from_packed(GameSettings.settings.Starting_Level)
	else:
		push_warning("[GameController] No initial scene assigned.")

func change_scene_from_packed(scene: PackedScene) -> void:
	if not scene or is_loading:
		return
	is_loading = true
	_unload_current_scene()
	_load_packed_scene(scene)

func _unload_current_scene() -> void:
	if current_scene:
		print("[GameController] Unloading scene:", current_scene_path)
		current_scene.queue_free()
		emit_signal("scene_unloaded", current_scene_path)
		current_scene = null
		current_scene_path = ""

func _load_packed_scene(scene: PackedScene) -> void:
	var new_scene = scene.instantiate()
	world_3d.add_child(new_scene)
	current_scene = new_scene
	current_scene_path = scene.resource_path
	is_loading = false
	print("[GameController] Loaded scene:", current_scene_path)
	emit_signal("scene_loaded", current_scene_path)
	emit_signal("scene_changed", "", current_scene_path)
	spawn_player()

# -------------------------------------------------------
# Player Spawn
# -------------------------------------------------------
func spawn_player() -> void:
	if not current_scene:
		push_error("[GameController] Cannot spawn player; no current scene.")
		return

	var spawn_marker: Marker3D = current_scene.find_child("PlayerSpawn", true, false)
	if not spawn_marker:
		push_warning("[GameController] No PlayerSpawn found in scene.")
		return

	if player and is_instance_valid(player):
		player.queue_free()

	if not player_scene:
		push_error("[GameController] No player scene assigned.")
		return

	player = player_scene.instantiate()
	world_3d.add_child(player)
	player.global_position = spawn_marker.global_position
	player.global_rotation = spawn_marker.global_rotation
	print("[GameController] Player spawned at:", spawn_marker.global_position)
	set_game_state(GameState.RUNNING)

# -------------------------------------------------------
# Game State
# -------------------------------------------------------

func set_game_state(state: GameState) -> void:
	if game_state == state:
		return
	game_state = state
	emit_signal("game_state_changed", state)
	match state:
		GameState.PAUSED:
			pause_menu.show_menu()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			print("[GameController] Game Paused")
		GameState.RUNNING:
			pause_menu.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_viewport().gui_release_focus()
			print("[GameController] Game Resumed")


func toggle_pause() -> void:
	print("toggling pause ", game_state)
	if game_state == GameState.RUNNING:
		set_game_state(GameState.PAUSED)
	else:
		set_game_state(GameState.RUNNING)
