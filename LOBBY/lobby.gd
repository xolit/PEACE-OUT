extends Control

#@onready var settings: Control = $settings
@onready var settings_btn: TextureButton = $settings_btn

var data: Dictionary

#sounds
@onready var click_sfx: AudioStreamPlayer = $click_sfx
@onready var back_sfx: AudioStreamPlayer = $back_sfx
@onready var menu_sfx: AudioStreamPlayer = $menu_sfx
@onready var lobby_sfx: AudioStreamPlayer = $lobby_sfx


@onready var ui_animation: AnimationPlayer = $UIAnimation


func _ready() -> void:
	data = GlobalSave.Contents_to_save

func _on_play_pressed() -> void:
	if data.get("Sfx", true):
		click_sfx.play()
	if lobby_sfx.playing:
		lobby_sfx.stop()
	#Global.change_scene("res://MAP/map.tscn")
	Global.change_scene("res://MAP/backrooms/scene/map.tscn")


func _on_quit_pressed() -> void:
	if data.get("Sfx", true):
		back_sfx.play()
	if lobby_sfx.playing:
		lobby_sfx.stop()
	get_tree().quit()


func _on_settings_btn_pressed() -> void:
	if data.get("Sfx", true):
		menu_sfx.play()
	#settings.show()
	if not ui_animation.is_playing():
		ui_animation.play("settings_on")
	settings_btn.hide()
