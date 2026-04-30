extends Control

@export var game_over_screen: Control 

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	# IMPORTANT: Make sure the pause menu doesn't block the mouse when hidden
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		if game_over_screen and game_over_screen.visible:
			return
			
		if get_tree().paused:
			_resume()
		else:
			_pause()

func _pause() -> void:
	get_tree().paused = true
	show()
	# Change filter so it catches the mouse clicks
	mouse_filter = Control.MOUSE_FILTER_STOP
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# This forces the buttons to look for the mouse immediately
	accept_event() 

func _resume() -> void:
	get_tree().paused = false
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_resume_button_pressed() -> void:
	_resume()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
