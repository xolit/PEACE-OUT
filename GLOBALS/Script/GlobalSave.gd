extends Node

var FileLocation: String = "user://User_data.save" # Use .save for binary data

var Contents_to_save: Dictionary = {
	"Music": true,
	"AllVolume": 100.0,
	"Sfx": true,
	"Senstivity": 0.002
}

func _ready() -> void:
	_load() # Just load the data
	# REMOVED: The DirAccess.remove_absolute block that was deleting your file!

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
