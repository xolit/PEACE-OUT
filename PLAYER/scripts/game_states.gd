extends Node

@onready var player: CharacterBody3D = $".."
@onready var fps_label: Label = $"../CanvasLayer/fps_Label"

func _save_game_state() -> void:
	Game.game_states["isGameSaved"] = true
	# 2. Update player position and rotation vectors directly
	var telemetry = Game.game_states.get("player_position_and_rotation", {})
	telemetry["position"] = player.global_position
	telemetry["rotation"] = player.global_rotation
	Game.game_states["player_position_and_rotation"] = telemetry
	Game._save()

func _process(delta: float) -> void:
	if GlobalSave.Contents_to_save.get("ShowFps", true):
		if fps_label.hidden: fps_label.show()
		fps_label.text = str(Engine.max_fps)
