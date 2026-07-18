extends Node

var anim_number_for: int = 0
var final_for_next_anim: String
var base_anim_name: String = "lobby_cutscene" # Fixed base name

@export var max_cutscenes: int = 2
@onready var lobby_anim: AnimationPlayer = $"../3dLobby/backroom/lobbyAnim"

func _on_lobby_anim_animation_finished(anim) -> void:
	anim_number_for += 1
	
	if anim_number_for > max_cutscenes:
		anim_number_for = 0 
		lobby_anim.play(base_anim_name)
		return 
		
	final_for_next_anim = base_anim_name + str(anim_number_for)
	lobby_anim.play(final_for_next_anim)
