extends Node3D

@onready var player: CharacterBody3D = $"../../../../.."

var start_pos: Vector3
var sway_rotation := Vector3.ZERO

@export var bob_speed := 8.0
@export var bob_amount := 0.03

@export var sway_amount := 0.002
@export var sway_smooth := 10.0

var bob_time := 0.0

func _ready():
	start_pos = position

func _process(delta):
	# =========================
	# MOVEMENT BOB
	# =========================
	if player.moving:
		var speed = Vector2(player.velocity.x, player.velocity.z).length()

		bob_time += delta * bob_speed * (speed / player.walk_speed)

		position.y = start_pos.y + sin(bob_time) * bob_amount
		position.x = start_pos.x + cos(bob_time * 0.5) * bob_amount * 0.5
	else:
		position = position.lerp(start_pos, delta * 6.0)

	# =========================
	# CAMERA SWAY
	# =========================
	var mouse_delta = player._camera_input

	var target_rot = Vector3(
		-mouse_delta.y * sway_amount,
		-mouse_delta.x * sway_amount,
		-mouse_delta.x * sway_amount * 0.5
	)

	sway_rotation = sway_rotation.lerp(
		target_rot,
		delta * sway_smooth
	)

	rotation = sway_rotation
