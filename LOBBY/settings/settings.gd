extends Control

#sounds
@export var lobby_sfx: AudioStreamPlayer
@export var click_sfx: AudioStreamPlayer
@export var back_sfx: AudioStreamPlayer

@onready var settings_ui: Control = $"."
@onready var settings_btn: TextureButton = $"../settings_btn"
@export var ui_anim: AnimationPlayer 

#nodes
@onready var player: CharacterBody3D

@onready var input_4_sens: LineEdit = $ScrollContainer/VBoxContainer/Senstivity/input4sens
@onready var music_btn: TextureButton = $ScrollContainer/VBoxContainer/Music/music_btn
@onready var sfx_btn: TextureButton = $ScrollContainer/VBoxContainer/sfx/sfx_btn
@onready var fog_btn: TextureButton = $ScrollContainer/VBoxContainer/fog/fog_btn
@onready var glow_btn: TextureButton = $ScrollContainer/VBoxContainer/glow/glow_btn
@onready var backcam_btn: TextureButton = $ScrollContainer/VBoxContainer/back_cam/backcam_btn
@onready var watertexture_btn: TextureButton = $ScrollContainer/VBoxContainer/watertexture/watertexture_btn
@onready var walltexture_btn: TextureButton = $ScrollContainer/VBoxContainer/walltexture/walltexture_btn

#display lobby btns on setting close
@onready var game_name: Label = $"../ColorRect/game_name"
@onready var play_text_btn: Button = $"../Control/play_text_btn"
@onready var quit_text_btn: Button = $"../Control/quit_text_btn"
@onready var settings_text_btn: Button = $"../Control/settings_text_btn"
@onready var show_fps_btn: TextureButton = $ScrollContainer/VBoxContainer/showFps/showFps_btn

#@onready var game_states: Node = $"../../game_states"


@onready var vol_slider: HSlider = $ScrollContainer/VBoxContainer/volume/VBoxContainer/vol_Slider
@onready var vol_label: Label = $ScrollContainer/VBoxContainer/volume/vol_percent

@export var is_lobby_setting: bool

@onready var fps_option_button: OptionButton = $ScrollContainer/VBoxContainer/fps/fpsOptionButton


var data: Dictionary
const fps_list = {
	0: 0,
	1: 90,
	2: 60,
	3: 30,
}

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	verify_audio_buses()
	data = GlobalSave.Contents_to_save
	apply_settings()

func _on_save_btn_pressed() -> void:
	if data.get("Sfx", true):
		back_sfx.play()
	if is_lobby_setting:
		if not ui_anim.is_playing():
			ui_anim.play("settings_off")
		game_name.show()
		settings_text_btn.show()
		quit_text_btn.show()
		play_text_btn.show()
	else:
		settings_ui.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	defaul_setting_checker()
	GlobalSave._save()

func _on_music_btn_toggled(toggled_on: bool) -> void:
	if data.get("Sfx", true):
		click_sfx.play()
	GlobalSave.Contents_to_save["Music"] = toggled_on
	update_bus_mute_state("Music", toggled_on)

func _on_sfx_btn_toggled(toggled_on: bool) -> void:
	if data.get("Sfx", true):
		click_sfx.play()
	GlobalSave.Contents_to_save["Sfx"] = toggled_on
	update_bus_mute_state("SFX", toggled_on)

func _on_fog_btn_toggled(toggled_on: bool) -> void:
	if data.get("Sfx", true):
		click_sfx.play()
	GlobalSave.Contents_to_save["fog"] = toggled_on

func _on_glow_btn_toggled(toggled_on: bool) -> void:
	if data.get("Sfx", true):
		click_sfx.play()
	GlobalSave.Contents_to_save["glow"] = toggled_on

func _on_vol_slider_value_changed(value: float) -> void:
	GlobalSave.Contents_to_save["AllVolume"] = value
	vol_label.text = str(int(round(value))) + "%"
	set_master_volume(value)


func _on_backcam_btn_toggled(toggled_on: bool) -> void:
	if data.get("Sfx", true):
		click_sfx.play()
	GlobalSave.Contents_to_save["backcam"] = toggled_on

func defaul_setting_checker() -> void:
	var new_sens_value: float = input_4_sens.text.to_float()
	var current_saved_value: float = float(GlobalSave.Contents_to_save.get("Senstivity", 0.002))
	if new_sens_value != current_saved_value:
		GlobalSave.Contents_to_save["Senstivity"] = new_sens_value
		
	var current_vol: float = float(GlobalSave.Contents_to_save.get("AllVolume", 100.0))
	if vol_slider.value != current_vol:
		GlobalSave.Contents_to_save["AllVolume"] = vol_slider.value
	

func apply_settings() -> void:
	var saved_fps := int(data.get("MaxFps", 0))
	for index in fps_list.keys():
		if fps_list[index] == saved_fps:
			fps_option_button.select(index)
			break
	
	input_4_sens.text = str(data.get("Senstivity", 0.002))
	
	var showFps_state: bool = data.get("ShowFps", true)
	show_fps_btn.button_pressed = showFps_state
	
	var music_state: bool = data.get("Music", true)
	music_btn.button_pressed = music_state
	update_bus_mute_state("Music", music_state)
	
	var sfx_state: bool = data.get("Sfx", true)
	sfx_btn.button_pressed = sfx_state
	update_bus_mute_state("SFX", sfx_state)
	
	
	var saved_vol: float = float(data.get("AllVolume", 100.0))
	vol_slider.value = saved_vol
	vol_label.text = str(int(round(saved_vol))) + "%"
	set_master_volume(saved_vol)
	
	var fog_state: bool = data.get("fog", true)
	fog_btn.button_pressed = fog_state
	
	var glow_state: bool = data.get("glow", true)
	glow_btn.button_pressed = glow_state
	
	var backcam_state: bool = data.get("backcam", true)
	backcam_btn.button_pressed = backcam_state
	
	var watertexture_state: bool = data.get("watertexture", true)
	watertexture_btn.button_pressed = watertexture_state
	
	var walltexture_state: bool = data.get("walltexture", true)
	walltexture_btn.button_pressed = walltexture_state
	
	
	if music_state and not lobby_sfx.playing:
		lobby_sfx.play()

func set_master_volume(value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index("Master")
	if bus_index != -1:
		if value <= 0:
			AudioServer.set_bus_mute(bus_index, true)
		else:
			AudioServer.set_bus_mute(bus_index, false)
			AudioServer.set_bus_volume_db(bus_index, linear_to_db(value / 100.0))

func update_bus_mute_state(bus_name: String, enabled: bool) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		AudioServer.set_bus_mute(bus_index, not enabled)

func verify_audio_buses() -> void:
	for bus_name in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var new_index: int = AudioServer.get_bus_count() - 1
			AudioServer.set_bus_name(new_index, bus_name)
			AudioServer.set_bus_send(new_index, "Master")


func _on_watertexture_btn_toggled(toggled_on: bool) -> void:
	if data.get("Sfx", true):
		click_sfx.play()
	GlobalSave.Contents_to_save["watertexture"] = toggled_on


func _on_walltexture_btn_toggled(toggled_on: bool) -> void:
	if data.get("Sfx", true):
		click_sfx.play()
	GlobalSave.Contents_to_save["walltexture"] = toggled_on


func _on_fps_option_button_item_selected(index: int) -> void:
	var selected_fps = fps_list[index]
	GlobalSave.Contents_to_save["MaxFps"] = selected_fps
	GlobalSave._new_fps_apply()


func _on_show_fps_btn_toggled(toggled_on: bool) -> void:
	if data.get("Sfx", true):
		click_sfx.play()
	GlobalSave.Contents_to_save["ShowFps"] = toggled_on
