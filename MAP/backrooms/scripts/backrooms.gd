extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var water: MeshInstance3D = $NavigationRegion3D/floor/water


func _ready() -> void:
	set_player_to_saved_pos()
	check_the_settins_of_environment()
	check_water()

func check_the_settins_of_environment() -> void:
	if GlobalSave.Contents_to_save["fog"]:
		world_environment.environment.fog_enabled = true
	else:
		world_environment.environment.fog_enabled = false
	
	if GlobalSave.Contents_to_save["glow"]:
		world_environment.environment.glow_enabled = true
	else:
		world_environment.environment.glow_enabled = false

func check_water()-> void:
	if not GlobalSave.Contents_to_save["watertexture"]:
		water.queue_free()

func set_player_to_saved_pos()-> void:
	if Game.game_states.get("isGameSaved", false):
		var telemetry = Game.game_states.get("player_position_and_rotation", {})
		## 2. Safely apply position and rotation if they exist in the dictionary
		if telemetry.has("position") and telemetry.has("rotation"):
			player.global_position = telemetry["position"]
			player.global_rotation = telemetry["rotation"]
			print("Player loaded at saved coordinates.")
