extends Control

var platform: String
@onready var mobile_check: CheckBox = $MOBLIE_Check
@onready var pc_check: CheckBox = $PC_Check

func _ready() -> void:
	# 1. Get the latest saved data
	platform = GlobalSave.Contents_to_save["platform"]
	
	# 2. Update the UI to match the data
	if platform == "MOBILE":
		mobile_check.set_pressed_no_signal(true)
		pc_check.set_pressed_no_signal(false)
	else:
		pc_check.set_pressed_no_signal(true)
		mobile_check.set_pressed_no_signal(false)

func _on_moblie_check_toggled(button_pressed: bool) -> void:
	if button_pressed:
		platform = "MOBILE"
		pc_check.set_pressed_no_signal(false)
		save_platform_choice() # Save the change
	else:
		mobile_check.set_pressed_no_signal(true)

func _on_pc_check_toggled(button_pressed: bool) -> void:
	if button_pressed:
		platform = "PC"
		mobile_check.set_pressed_no_signal(false)
		save_platform_choice() # Save the change
	else:
		pc_check.set_pressed_no_signal(true)

# Helper function to update the GlobalSave dictionary and save to disk
func save_platform_choice() -> void:
	GlobalSave.Contents_to_save["platform"] = platform
	GlobalSave._save()

func _on_play_pressed() -> void:
	Global.change_scene("res://MAP/map.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
