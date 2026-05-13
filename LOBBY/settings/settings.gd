extends Control

#sounds
@onready var lobby_sfx: AudioStreamPlayer = $"../lobby_sfx"
@onready var click_sfx: AudioStreamPlayer = $"../click_sfx"
@onready var back_sfx: AudioStreamPlayer = $"../back_sfx"

@onready var settings_ui: Control = $"."
@onready var settings_btn: TextureButton = $"../settings_btn"

#nodes
@onready var input_4_sens: LineEdit = $ScrollContainer/VBoxContainer/Senstivity/input4sens
@onready var music_btn: TextureButton = $ScrollContainer/VBoxContainer/Music/music_btn
@onready var sfx_btn: TextureButton = $ScrollContainer/VBoxContainer/sfx/sfx_btn
@onready var vol_slider: HSlider = $ScrollContainer/VBoxContainer/volume/VBoxContainer/vol_Slider
@onready var vol_label: Label = $ScrollContainer/VBoxContainer/volume/VBoxContainer/vol_label

var data: Dictionary

func _ready() -> void:
	verify_audio_buses()
	data = GlobalSave.Contents_to_save
	apply_settings()

func _on_save_btn_pressed() -> void:
	if data.get("Sfx", true):
		back_sfx.play()
	settings_btn.show()
	if settings_ui.visible:
		settings_ui.hide()
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

func _on_vol_slider_value_changed(value: float) -> void:
	GlobalSave.Contents_to_save["AllVolume"] = value
	vol_label.text = str(int(round(value))) + "%"
	set_master_volume(value)

func defaul_setting_checker() -> void:
	var new_sens_value: float = input_4_sens.text.to_float()
	var current_saved_value: float = float(GlobalSave.Contents_to_save.get("Senstivity", 0.002))
	if new_sens_value != current_saved_value:
		GlobalSave.Contents_to_save["Senstivity"] = new_sens_value
		
	var current_vol: float = float(GlobalSave.Contents_to_save.get("AllVolume", 100.0))
	if vol_slider.value != current_vol:
		GlobalSave.Contents_to_save["AllVolume"] = vol_slider.value

func apply_settings() -> void:
	input_4_sens.text = str(data.get("Senstivity", 0.002))
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
