extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var head_cast: RayCast3D = $Head/HeadCast
@onready var interaction_cast: RayCast3D = $Head/InteractionCast
@onready var ui = get_node("Crosshair")
@onready var mic_system: Node = $Head/MicSystem
@onready var hand_marker: Marker3D = $Head/HandMarker




var sprint_speed :float= GameSettings.settings.player_sprint_speed
var jump_velocity := GameSettings.settings.player_jump_velocity
var speed := GameSettings.settings.player_speed
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var pitch := 0.0
var controller: GameController = GameController._instance
var is_crouching:bool = false
var _crouch_tween: Tween
var hovered: Node = null

var equipped_item: Node3D = null
func _ready():
	print("player is ready")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if camera:
		camera.current = true
		camera.fov = GameSettings.settings.base_fov
	
	interaction_cast.target_position = Vector3(0,0, -GameSettings.settings.interaction_distance)
	
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
	
	if event.is_action_pressed("crouch"):
		_set_crouching(true)
	elif event.is_action_released("crouch"):
		if head_cast.is_colliding(): return
		_set_crouching(false)

func _set_crouching(enable: bool):
	if is_crouching == enable: return
	
	is_crouching = enable
	var settings = GameSettings.settings
	var target_height = settings.crouch_height if is_crouching else settings.standing_height
	var shape = collision.shape as CapsuleShape3D
	if shape == null:
		push_warning("can't find collision for player to crouch")
		return
	
	if _crouch_tween and _crouch_tween.is_running():
		_crouch_tween.kill()
	
	_crouch_tween = create_tween()
	_crouch_tween.tween_property(shape, "height", target_height, settings.crouch_transition_time)
	
	var head_target_y = target_height *0.5
	_crouch_tween.tween_property(head, "position:y", head_target_y, settings.crouch_transition_time)

func _process(delta):
	var target_fov := camera.fov
	
	if GameSettings.settings:
		var base_fov := GameSettings.settings.base_fov
		var sprint_fov := GameSettings.settings.sprint_fov
		var fov_smooth_speed := GameSettings.settings.fov_smooth_speed
		var sprinting := Input.is_action_pressed("sprint")
		if is_crouching and sprinting: sprinting = false
		target_fov = sprint_fov if sprinting else base_fov
		camera.fov = lerp(camera.fov, target_fov, delta * fov_smooth_speed)


func _physics_process(delta: float) -> void:
	if controller.game_state != controller.GameState.RUNNING: return
	_movement(delta)
	_interaction(delta)

func _movement(delta:float):
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	var direction = (right * input_dir.x + forward * input_dir.y).normalized()

	direction.y = 0
	direction = direction.normalized()
	var target_speed = (sprint_speed as float) if Input.is_action_pressed("sprint") else (speed as float)
	if is_crouching:
		target_speed *= GameSettings.settings.crouch_speed
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



## ----- INTERACTION -----
func _interaction(_delta:float):
	interaction_cast.force_raycast_update()
	var target: Node  = _get_target()
	if target != hovered:
		if not target:
			print("no target. Hiding prompt for ", hovered)
			ui.hide_prompt()
		else:
			print("Showing prompt target.get_prompt_text")
			ui.show_prompt()
		
		hovered = target
	
	if hovered and Input.is_action_just_pressed("interact"):
		hovered.interact(self)

func _get_target() -> Node:
	var hit = interaction_cast.get_collider()
	if hit:
		var n = hit as Node
		while n:
			if n.has_method("interact"):
				return n
			n = n.get_parent()
	return null


func equip_item(item:Node3D):
	if equipped_item:
		equipped_item.queue_free()

	equipped_item = item
	equipped_item.equipped = true
	equipped_item.get_parent().remove_child(equipped_item)
	hand_marker.add_child(equipped_item)
	equipped_item.transform = Transform3D.IDENTITY
	equipped_item.scale = Vector3.ONE
	equipped_item.position = Vector3.ZERO
	equipped_item.rotation = Vector3.ZERO

	if equipped_item.has_method("on_equipped"):
		equipped_item.on_equipped()
	
	print("🔧 Equipped:", equipped_item.name)


func add_to_inventory(item: Node3D):
	item.queue_free()
	print("📦 Added ", item.name, " to inventory (placeholder).")
