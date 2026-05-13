extends Node3D

var door_open: bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _toggle_door() -> bool:
	if animation_player.is_playing():
		return door_open # Return current state if busy
	
	if not door_open:
		animation_player.play("door_open")
		door_open = true
	else:
		animation_player.play("door_close")
		door_open = false
		
	return door_open
