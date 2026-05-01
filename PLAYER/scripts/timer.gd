extends Node

@onready var timer: Timer = $Timer
@onready var timer_label: Label = $"." # Assuming the script is on the Label itself

@export var start_minutes: int = 1
@export var start_seconds: int = 30

func _ready() -> void:
	# Calculate total seconds and start the timer
	var total_seconds = (start_minutes * 60) + start_seconds
	timer.wait_time = total_seconds
	timer.one_shot = true
	timer.start()
	
	# Connect the timeout signal via code (or do it in the editor)
	timer.timeout.connect(_on_timer_timeout)

func _process(_delta: float) -> void:
	# Get the time left from the timer node
	var time_left = timer.time_left
	
	# Math to break it down into minutes and seconds
	var m = int(time_left) / 60
	var s = int(time_left) % 60
	
	# Update the label text with nice formatting (e.g., 01:05)
	timer_label.text = "%02d:%02d" % [m, s]

func _on_timer_timeout() -> void:
	print("GAMEOVER")
	# You can add code here to change scenes or stop the player
