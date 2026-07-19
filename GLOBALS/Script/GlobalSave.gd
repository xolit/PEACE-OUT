extends Node

var FileLocation: String = "user://User_data.save" # Use .save for binary data

var Contents_to_save: Dictionary = {
	"MaxFps": 0,
	"ShowFps": false,
	"Music": true,
	"AllVolume": 100.0,
	"Sfx": true,
	"Bones": true,
	"fog": true,
	"glow": true,
	"backcam": true,
	"watertexture": true,
	"walltexture": true,
	"Senstivity": 0.002
}

func _ready() -> void:
	_load()
	_new_fps_apply()


func _save() -> void:
	var file := FileAccess.open(FileLocation, FileAccess.WRITE)
	if file:
		# Use store_var(data) to match your get_var() in _load
		file.store_var(Contents_to_save)
		file.close()

func _load() -> Dictionary:
	if FileAccess.file_exists(FileLocation):
		var file := FileAccess.open(FileLocation, FileAccess.READ)
		if file:
			var data = file.get_var()
			file.close()
			if data is Dictionary:
				Contents_to_save = data
	else:
		_save() # Create default file if it doesn't exist
	return Contents_to_save

func _new_fps_apply() -> void:
	Engine.max_fps = Contents_to_save.get("MaxFps", 0)
