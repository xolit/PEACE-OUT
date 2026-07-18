extends Node

@onready var timer: Timer = $Timer
@onready var timer_label: Label = $"."
@onready var player: CharacterBody3D = $"../.."

@export var start_minutes: int = 1
@export var start_seconds: int = 30

func _ready() -> void:
	_apply_settings_saved()

	var total_seconds = (start_minutes * 60) + start_seconds

	timer.wait_time = total_seconds
	timer.one_shot = true
	timer.start()

	timer.timeout.connect(_on_timer_timeout)

func _process(_delta: float) -> void:
	var time_left = timer.time_left

	var m = int(time_left) / 60
	var s = int(time_left) % 60

	timer_label.text = "%02d:%02d" % [m, s]

func _on_timer_timeout() -> void:
	print("GAMEOVER")
	player._die(true)

func _apply_settings_saved() -> void:
	if Game.game_states["isGameSaved"]:
		var saved_time: String = Game.game_states["timer"]

		var parts = saved_time.split(".")

		if parts.size() == 2:
			start_minutes = int(parts[0])
			start_seconds = int(parts[1])
