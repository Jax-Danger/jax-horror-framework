extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

var sprint_speed :float= GameSettings.settings.player_sprint_speed
var jump_velocity := GameSettings.settings.player_jump_velocity
var speed := GameSettings.settings.player_speed
var gravity := ProjectSettings.get_setting("physics/3d/default_gravity")
var pitch := 0.0
var controller: GameController = GameController._instance

func _ready():
	print("player is ready")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if camera:
		camera.current = true
		camera.fov = GameSettings.settings.base_fov
	
	controller.game_state_changed.connect(_on_game_state_changed)
	_on_game_state_changed(controller.game_state)
	GameSettings.connect("settings_changed", Callable(self, "_on_settings_changed"))
	
func _on_game_state_changed(state:int)->void:
	if state == GameController.GameState.RUNNING:
		_enable_control()
		print("Controls enabled")
	else:
		_disable_control()
		print("controls disabled")

func _enable_control():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _disable_control():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event: InputEvent) -> void:
	if controller.game_state != controller.GameState.RUNNING: return
	if event is InputEventMouseMotion:
		var sens := GameSettings.get_normalized_sensitivity()
		rotate_y(-event.relative.x * sens * 0.1)
		pitch = clamp(pitch - event.relative.y * sens * 0.1, -1.3, 1.3)
		head.rotation.x = pitch

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		controller.toggle_pause()
		print("Paussing from player_controller")


func _process(delta):
	var sens :float= GameSettings.get_normalized_sensitivity()
	var target_fov := camera.fov
	
	if GameSettings.settings:
		var base_fov := GameSettings.settings.base_fov
		var sprint_fov := GameSettings.settings.sprint_fov
		var fov_smooth_speed := GameSettings.settings.fov_smooth_speed
		var sprinting := Input.is_action_pressed("sprint")
		target_fov = sprint_fov if sprinting else base_fov
		camera.fov = lerp(camera.fov, target_fov, delta * fov_smooth_speed)


func _physics_process(delta: float) -> void:
	if controller.game_state != controller.GameState.RUNNING: return

	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	var direction = (right * input_dir.x + forward * input_dir.y).normalized()

	direction.y = 0
	direction = direction.normalized()

	var target_speed = sprint_speed if Input.is_action_pressed("sprint") else speed
	velocity.x = direction.x * target_speed
	velocity.z = direction.z * target_speed
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
	
	move_and_slide()

func _on_settings_changed():
	# Reapply settings in real time
	var s = GameSettings.settings
	camera.fov = s.base_fov
	s.sprint_fov = s.base_fov + 10.0
