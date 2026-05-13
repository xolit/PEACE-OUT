extends Control

@export var progress_bar: ProgressBar 
var progress := 0.0

func _ready() -> void:
	var ui_nodes = get_tree().get_nodes_in_group("ui")
	if ui_nodes.size() > 0:
		var canvas = ui_nodes[0]
		if canvas is CanvasLayer or canvas is Control:
			canvas.hide()
	else:
		push_warning("No CanvasLayer found in group 'ui'")

func set_progress(value: float):
	progress = clamp(value, 0.0, 100.0)
	progress_bar.value = progress * 100.0
