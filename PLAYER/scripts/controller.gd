extends CharacterBody3D

## --- Exports ---
@export_group("Movement")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 12.0
@export var jump_velocity: float = 4.5
@export var acceleration: float = 10.0

@export_group("Camera Settings")
@export var mouse_sensitivity: float = 0.002
@export var touch_sensitivity: float = 0.0015
@export var smoothing_weight: float = 20.0

@export_group("Total enemies map")
@export var Total_enemies: Array[CharacterBody3D]

## --- Nodes ---
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var mobile_controls: Control = $CanvasLayer/mobile_controls
@onready var rear_marker = $CanvasLayer/SubViewportContainer/SubViewport/rear_cam_marker
@onready var rear_camera = $CanvasLayer/SubViewportContainer/SubViewport/rear_cam_marker/back_cam
@onready var health_bar: ProgressBar = $CanvasLayer/health_bar
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gameover: Control = $CanvasLayer/gameover

#sounds
@onready var run_sfx: AudioStreamPlayer3D = $run_sfx

## --- Internal Variables ---
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _current_speed: float = walk_speed
var _camera_input: Vector2 = Vector2.ZERO
var _rotation_target: Vector3 = Vector3.ZERO
var Health: float = 100.0

func _ready() -> void:
	Input.set_use_accumulated_input(false)
	
	# Initial camera sync
	_rotation_target.y = rotation.y
	_rotation_target.x = camera.rotation.x
	
	# Load platform preference from GlobalSave
	var saved_platform = GlobalSave.Contents_to_save.get("platform", "PC")
	
	_apply_platform_settings(saved_platform)

func _apply_platform_settings(platform: String) -> void:
	if platform == "PC":
		# PC Setup
		mobile_controls.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		# Emulation: We want touch to act like mouse (for UI)
		# but we don't want mouse to act like touch
		_setup_device_emulation(false, true) 
	else:
		# Mobile Setup
		mobile_controls.show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		# Emulation: We want mouse to act like touch (for testing on PC)
		_setup_device_emulation(true, false)

func _input(event: InputEvent) -> void:
	# Mouse handling
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_camera_input += event.relative * mouse_sensitivity
		
	# Touch handling
	if event is InputEventScreenDrag:
		_camera_input += event.relative * touch_sensitivity

func _process(delta: float) -> void:
	rear_camera.global_transform = rear_marker.global_transform
	_handle_camera_rotation(delta)

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_handle_sprint()
	_handle_movement(delta) 
	_handle_sounds()
	move_and_slide()

## --- Logic Functions ---

func _handle_camera_rotation(delta: float) -> void:
	_rotation_target.y -= _camera_input.x
	_rotation_target.x -= _camera_input.y
	_rotation_target.x = clamp(_rotation_target.x, deg_to_rad(-90), deg_to_rad(90))
	
	_camera_input = Vector2.ZERO # Clear buffer
	
	rotation.y = lerp_angle(rotation.y, _rotation_target.y, smoothing_weight * delta)
	camera.rotation.x = lerp_angle(camera.rotation.x, _rotation_target.x, smoothing_weight * delta)

func _handle_movement(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() 
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * _current_speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * _current_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, _current_speed * acceleration * delta)
		velocity.z = move_toward(velocity.z, 0, _current_speed * acceleration * delta)

func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func _handle_sounds() -> void:
	# Check if the player is on the floor and actually moving
	# We use a small threshold (0.1) to avoid sounds when barely sliding
	var horizontal_velocity = Vector2(velocity.x, velocity.z).length()
	
	if is_on_floor() and horizontal_velocity > 0.1:
		if not run_sfx.playing:
			run_sfx.play()
		
		# Optional: Speed up the audio pitch when sprinting
		run_sfx.pitch_scale = 1.2 if _current_speed == sprint_speed else 1.0
	else:
		if run_sfx.playing:
			run_sfx.stop()

func _handle_sprint() -> void:
	# Sprint only if moving forward (y < 0 in get_vector)
	var is_moving_forward = Input.get_vector("left", "right", "up", "down").y < -0.1
	if Input.is_action_pressed("sprint") and is_moving_forward:
		_current_speed = sprint_speed
	else:
		_current_speed = walk_speed

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

## --- Helpers ---

func _setup_device_emulation(touch_from_mouse: bool, mouse_from_touch: bool) -> void:
	# ProjectSettings.set_setting requires a restart to take effect in some cases, 
	# but setting it here ensures consistent behavior in exported builds.
	ProjectSettings.set_setting("input_devices/pointing/emulate_touch_from_mouse", touch_from_mouse)
	ProjectSettings.set_setting("input_devices/pointing/emulate_mouse_from_touch", mouse_from_touch)

func _damage() -> void:
	# 1. Subtract health first
	Health -= 10
	
	# 2. Update UI
	if health_bar:
		health_bar.value = Health
	
	# 3. Play animation
	if animation_player.has_animation("damage"):
		animation_player.play("damage")
	
	# 4. Check for death
	if Health <= 0:
		_die()

func _die() -> void:
	Health = 0
	# 1. Show cursor and Game Over screen
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	gameover.show()
	
	# 2. Stop this node from taking input
	set_process_input(false)
	set_physics_process(false)
	set_process(false)
	
	# 3. Clean up enemies
	for enemy in Total_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	Total_enemies.clear()



func _on_button_button_down() -> void:
	get_tree().paused = false # Add this line
	get_tree().reload_current_scene()
