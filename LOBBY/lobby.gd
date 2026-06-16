extends Control

#@onready var settings: Control = $settings
@onready var settings_btn: TextureButton = $settings_btn

var data: Dictionary

#sounds
@onready var click_sfx: AudioStreamPlayer = $click_sfx
@onready var back_sfx: AudioStreamPlayer = $back_sfx
@onready var menu_sfx: AudioStreamPlayer = $menu_sfx
@onready var lobby_sfx: AudioStreamPlayer = $lobby_sfx
@onready var game_version: Label = $ColorRect/game_version

#btns to hide on seting show
@onready var play_text_btn: Button = $Control/play_text_btn
@onready var quit_text_btn: Button = $Control/quit_text_btn
@onready var settings_text_btn: Button = $Control/settings_text_btn
@onready var game_name: Label = $ColorRect/game_name



@onready var ui_animation: AnimationPlayer = $UIAnimation


func _ready() -> void:
	data = GlobalSave.Contents_to_save
	game_version.text = "v"+ProjectSettings.get_setting("application/config/version")

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
	
	#hide elements on setting show up
	settings_text_btn.hide()
	play_text_btn.hide()
	quit_text_btn.hide()
	game_name.hide()
	
	
	if not ui_animation.is_playing():
		ui_animation.play("settings_on")
	settings_btn.hide()
