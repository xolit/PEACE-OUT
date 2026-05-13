extends Node

@onready var menu_btn: TextureButton = $"../CanvasLayer/settings/menu"
@onready var menu_ui: Control = $"../CanvasLayer/menu_ui"
@onready var door_colliding_label: Label = $"../CanvasLayer/door_colliding_label"
@onready var gameover: Control = $"../CanvasLayer/gameover"
@onready var game_over_sfx: AudioStreamPlayer = $"../CanvasLayer/gameover/game_over"

var door_opn_txt: bool = false

func _process(_delta: float) -> void:
	if door_opn_txt:
		_door_is_colliding(true)
	else: _door_is_colliding(false)

func _on_menu_pressed() -> void:
	menu_ui.show()

func _on_go_to_menu_pressed() -> void:
	Global.change_scene("res://LOBBY/lobby.tscn")
	menu_ui.hide()

func _on_cencel_pressed() -> void:
	menu_ui.hide()

func _door_is_colliding(status: bool)->void:
	door_colliding_label.visible = status
	door_colliding_label.text = "Interact With Door"

func _game_over()-> void:
	gameover.show()
	game_over_sfx.play()
