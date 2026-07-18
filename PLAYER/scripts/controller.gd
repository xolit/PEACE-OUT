extends CharacterBody3D

## --- Exports ---
@export_group("Movement")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 12.0
@export var jump_velocity: float = 4.5
@export var acceleration: float = 10.0

@export_group("Camera Settings")
@export var mouse_sensitivity: float = float(GlobalSave.Contents_to_save.get("Senstivity"))
@export var smoothing_weight: float = 20.0

@export_group("Total enemies map")
@export var Total_enemies: Array[CharacterBody3D]

@export_group("Camera Juice")
@export var bob_speed := 10.0
@export var bob_amount := 0.06
@export var sprint_fov := 85.0
@export var normal_fov := 75.0
@export var fov_lerp_speed := 8.0
@export var tilt_amount := 2.0

var bob_time := 0.0
var camera_origin : Vector3

var touch_dragging := false
var last_touch_position := Vector2.ZERO

@export var touch_sensitivity := 0.005

## --- Nodes ---
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var rear_marker = $CanvasLayer/back_cam/SubViewport/rear_cam_marker
@onready var rear_camera = $CanvasLayer/back_cam/SubViewport/rear_cam_marker/back_cam
@onready var health_bar: ProgressBar = $CanvasLayer/health_bar
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ray_coll: RayCast3D = $Head/Camera3D/RayCast3D


#hands
@onready var right_hand = $Head/Camera3D/hand/right

@onready var menu_exit_btn: TouchScreenButton = $CanvasLayer/menu
#@onready var settings_btn: TextureButton = $CanvasLayer/settings_btn


var sound_tween: Tween
@onready var menu_handler: Node = $Menu_handler

#player states
var moving: bool

# Sounds
@onready var run_sfx: AudioStreamPlayer3D = $run_sfx

## --- Internal Variables ---
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _current_speed: float = walk_speed
var _camera_input: Vector2 = Vector2.ZERO
var _rotation_target: Vector3 = Vector3.ZERO
var Health: float = 100.0

func _ready() -> void:
	add_to_group("player")
	if Game.game_states["isGameSaved"] == false:
		Game.game_states["isGameSaved"] = true
		Game._save()
	Input.set_use_accumulated_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	camera_origin = camera.position
	camera.fov = normal_fov
	
	# Initial camera sync
	_rotation_target.y = rotation.y
	_rotation_target.x = camera.rotation.x

func _input(event: InputEvent) -> void:
	# Desktop
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_camera_input += event.relative * mouse_sensitivity

	# Mobile
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_dragging = true
			last_touch_position = event.position
		else:
			touch_dragging = false

	if event is InputEventScreenDrag and touch_dragging:
		_camera_input.x += event.relative.x * touch_sensitivity
		_camera_input.y += event.relative.y * touch_sensitivity

func _process(delta: float) -> void:
	rear_camera.global_transform = rear_marker.global_transform
	_handle_camera_rotation(delta)
	_camera_juice(delta)

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_handle_sprint()
	_handle_movement(delta)
	_handle_sounds()
	_check_collision()
	move_and_slide()
	if Input.is_action_just_pressed("esc"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			menu_exit_btn.show()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			menu_exit_btn.hide()

## --- Logic Functions ---
func _check_collision() -> void:
	if ray_coll.is_colliding():
		var collider = ray_coll.get_collider()
		var door = collider.get_parent()
		if door and (door.name.to_lower().contains("door") or door.is_in_group("door")):
			menu_handler.door_opn_txt = true
			if Input.is_action_just_pressed("interact"):
				var door_cool = collider
				# climb up until we find the node that has the door script
				while door_cool and not door_cool.has_method("_toggle_door"):
					door_cool = door_cool.get_parent()
				if door_cool:
					door_cool._toggle_door()
		else:
			menu_handler.door_opn_txt = false
	else:
		menu_handler.door_opn_txt = false

func _handle_camera_rotation(delta: float) -> void:
	_rotation_target.y -= _camera_input.x
	_rotation_target.x -= _camera_input.y

	_rotation_target.x = clamp(
		_rotation_target.x,
		deg_to_rad(-90),
		deg_to_rad(90)
	)

	_camera_input = Vector2.ZERO

	rotation.y = lerp_angle(
		rotation.y,
		_rotation_target.y,
		smoothing_weight * delta
	)

	camera.rotation.x = lerp_angle(
		camera.rotation.x,
		_rotation_target.x,
		smoothing_weight * delta
	)

func _handle_movement(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = lerp(velocity.x, direction.x * _current_speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * _current_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, _current_speed * acceleration * delta)
		velocity.z = move_toward(velocity.z, 0, _current_speed * acceleration * delta)

	moving = Vector2(velocity.x, velocity.z).length() > 0.1 and is_on_floor()

func _camera_juice(delta):
	var speed := Vector2(velocity.x, velocity.z).length()

	# HEAD BOB (Y only)
	if is_on_floor() and speed > 0.1:
		var bob_multiplier := 1.0

		if _current_speed == sprint_speed:
			bob_multiplier = 1.5

		bob_time += delta * bob_speed * bob_multiplier

		camera.position.y = camera_origin.y + sin(bob_time) * bob_amount
	else:
		camera.position.y = lerp(
			camera.position.y,
			camera_origin.y,
			delta * 8.0
		)

	# Keep X fixed to prevent clipping
	camera.position.x = camera_origin.x
	camera.position.z = camera_origin.z

	# FOV EFFECT
	var target_fov := normal_fov

	if _current_speed == sprint_speed:
		target_fov = sprint_fov

	camera.fov = lerp(
		camera.fov,
		target_fov,
		delta * fov_lerp_speed
	)

	# LIGHT STRAFE TILT
	var input_x := Input.get_axis("left", "right")
	var target_roll := deg_to_rad(-input_x * tilt_amount)

	camera.rotation.z = lerp(
		camera.rotation.z,
		target_roll,
		delta * 6.0
	)

func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

#func _handle_sounds() -> void:
	#var horizontal_velocity = Vector2(velocity.x, velocity.z).length()
	#
	#if is_on_floor() and horizontal_velocity > 0.1:
		#if not run_sfx.playing:
			#run_sfx.play()
		#run_sfx.pitch_scale = 1.2 if _current_speed == sprint_speed else 1.0
	#else:
		#if run_sfx.playing:
			#run_sfx.stop() 

func _handle_sounds():
	var horizontal_velocity := Vector2(velocity.x, velocity.z).length()

	if is_on_floor() and horizontal_velocity > 0.1 and GlobalSave.Contents_to_save.get("Sfx", true):
		if !run_sfx.playing:
			print("PLAY")
			run_sfx.play()
	else:
		if run_sfx.playing:
			print("STOP")
			run_sfx.stop()

func _handle_sprint() -> void:
	var is_moving_forward = Input.get_vector("left", "right", "up", "down").y < -0.1
	if Input.is_action_pressed("sprint") and is_moving_forward:
		_current_speed = sprint_speed
	else:
		_current_speed = walk_speed

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

## --- Helpers ---
func _damage() -> void:
	Health -= 10
	if health_bar:
		health_bar.value = Health
	if animation_player.has_animation("damage"):
		animation_player.play("damage")
	if Health <= 0:
		_die(false)

func _die(timeover) -> void:
	Health = 0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if timeover:
		menu_handler._game_over(true)
	else:
		menu_handler._game_over(false)
	
	set_process_input(false)
	set_physics_process(false)
	set_process(false)
	
	for enemy in Total_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	Total_enemies.clear()

func _on_button_button_down() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
