extends Node

var FileLocation: String = "user://game.save"

var game_states: Dictionary = {
	"isGameSaved": false,
	"book": false, 
	"lighter": false, 
	"player_position_and_rotation": { 
		"x_pos": 12.397, 
		"y_pos": 0.0, 
		"z_pos": -49.157, 
		"x_rota": 0.0, 
		"y_rota": -115.2, 
		"z_rota": 0.0 
	} 
}

func _save() -> void:
	var file := FileAccess.open(FileLocation, FileAccess.WRITE)
	if file:
		file.store_var(game_states)
		file.close()

func _load() -> Dictionary:
	if FileAccess.file_exists(FileLocation):
		var file := FileAccess.open(FileLocation, FileAccess.READ)
		if file:
			var data = file.get_var()
			file.close()
			if data is Dictionary:
				game_states = data
	else:
		_save()
	return game_states
