extends Control

@export var progress_bar: ProgressBar 

var progress := 0.0

func set_progress(value: float):
	progress = clamp(value, 0.0, 100.0)
	progress_bar.value = progress * 100.0
