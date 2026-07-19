extends Node


@onready var menu_ui: Control = $"../CanvasLayer/menu_ui"
@onready var door_colliding_label: Label = $"../CanvasLayer/door_colliding_label"
@onready var gameover: Control = $"../CanvasLayer/gameover"
@onready var game_over_sfx: AudioStreamPlayer = $"../CanvasLayer/gameover/game_over"
@onready var gameover_label: Label = $"../CanvasLayer/gameover/gameover_label"
@onready var back_cam: SubViewportContainer = $"../CanvasLayer/back_cam"
@onready var timer_label: Label = $"../CanvasLayer/timer_label"
@onready var crosshair: TextureRect = $"../CanvasLayer/crosshair"
@onready var health_bar: ProgressBar = $"../CanvasLayer/health_bar"
@onready var game_states: Node = $"../game_states"
@onready var mobilecontrols: Control = $"../CanvasLayer/MOBILECONTROLS"

var door_opn_txt: bool = false

func _ready() -> void:
	if GlobalSave.Contents_to_save.get("backcam", true):
		back_cam.show()
	else: 
		back_cam.hide()

func _process(_delta: float) -> void:
	if door_opn_txt:
		_door_is_colliding(true)
	else: _door_is_colliding(false)

func _on_go_to_menu_pressed() -> void:
	menu_ui.show()
	mobilecontrols.hide()
	back_cam.hide()
	timer_label.hide()
	health_bar.hide()
	crosshair.hide()

func _on_cencel_pressed() -> void:
	menu_ui.hide()
	mobilecontrols.show()
	back_cam.show()
	timer_label.show()
	health_bar.show()
	crosshair.show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _door_is_colliding(status: bool)->void:
	door_colliding_label.visible = status
	door_colliding_label.text = "Interact With [E]"

func _game_over(gameoverbytime) -> void:
	if gameoverbytime:
		gameover_label.text = "Developer Is Mad. You Died!"
	else:
		gameover_label.text = "Monster Killed You!"
	gameover.show()
	game_over_sfx.play()
	await get_tree().create_timer(5.0).timeout
	Global.change_scene("res://LOBBY/lobby.tscn")

func _on_go_to_lobby_pressed() -> void:
	game_states._save_game_state()
	Game.game_states["health"] = health_bar.value
	Game.game_states["timer"] = timer_label.text
	Game._save()
	Global.change_scene("res://LOBBY/lobby.tscn")
