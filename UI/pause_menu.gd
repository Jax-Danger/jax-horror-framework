extends Control

@onready var sensitivity_slider: HSlider = $Panel/TabContainer/Mouse/SensitivityBox/SensitivityHBox/SensitivitySlider
@onready var sensitivity_percentage_label: Label = $Panel/TabContainer/Mouse/SensitivityBox/SensitivityHBox/SensitivityPercentageLabel
@onready var sens_reset_btn: Button = $Panel/TabContainer/Mouse/SensitivityBox/LabelContainer/sensResetBtn
@onready var fov_slider: HSlider = $Panel/TabContainer/Mouse/FOVBox/FOVHBox/FOVSlider
@onready var fov_percentage_label: Label = $Panel/TabContainer/Mouse/FOVBox/FOVHBox/FOVPercentageLabel
@onready var fov_reset_btn: Button = $Panel/TabContainer/Mouse/FOVBox/LabelContainer/FOVResetBtn
@onready var master_vol_percentage_label: Label = $Panel/TabContainer/Audio/MasterVolBox/MasterVolPercentageLabel
@onready var master_vol_slider: HSlider = $Panel/TabContainer/Audio/MasterVolBox/MasterVolSlider
@onready var music_vol_slider: HSlider = $Panel/TabContainer/Audio/MusicVolBox/MusicVolSlider
@onready var music_vol_percentage_label: Label = $Panel/TabContainer/Audio/MusicVolBox/MusicVolPercentageLabel
@onready var env_vol_slider: HSlider = $Panel/TabContainer/Audio/EnvVolBox/EnvVolSlider
@onready var env_vol_percentage_label: Label = $Panel/TabContainer/Audio/EnvVolBox/EnvVolPercentageLabel
@onready var resume_button: Button = $Panel/TabContainer/Pause/HBoxContainer2/VBoxContainer2/ResumeButton
@onready var quit_button: Button = $Panel/TabContainer/Pause/HBoxContainer2/VBoxContainer2/QuitButton
@onready var pause_tab: VBoxContainer = $Panel/TabContainer/Pause

var default_fov = GameSettings.settings.default_fov
var default_sens = GameSettings.settings.default_sensitivity

# Audio
var mastVol = AudioServer.get_bus_index("Master")
var envVol = AudioServer.get_bus_index("Environment")
var musicVol = AudioServer.get_bus_index("Music")

func _ready():
	visible = false
	_load_settings()
	_connect_signals()
	if sensitivity_slider.value > default_sens or sensitivity_slider.value < default_sens:
		sens_reset_btn.visible = true
	else: sens_reset_btn.visible = false
	
	if fov_slider.value > default_fov or fov_slider.value < default_fov:
		fov_reset_btn.visible = true
	else: fov_reset_btn.visible = false



func _load_settings():
	var s = GameSettings.settings
	sensitivity_slider.value = s.mouse_sensitivity
	sensitivity_percentage_label.text = str(sensitivity_slider.value) + " %"
	fov_slider.value = s.base_fov
	fov_percentage_label.text = str(fov_slider.value) + " %"
	
	env_vol_slider.value = s.envVol
	music_vol_slider.value = s.musicVol
	master_vol_slider.value = s.masterVol
	env_vol_percentage_label.text = str(s.envVol) + "dB"
	master_vol_percentage_label.text = str(s.masterVol) + "dB"
	music_vol_percentage_label.text = str(s.musicVol) + "dB"

func _connect_signals():
	sensitivity_slider.connect("value_changed", Callable(self, "_on_sensitivity_changed"))
	sens_reset_btn.connect("pressed", Callable(self, "_on_sensReset_pressed"))
	
	fov_slider.connect("value_changed", Callable(self, "_on_fov_changed"))
	fov_reset_btn.connect("pressed", Callable(self, "_onfovreset_pressed"))
	master_vol_slider.connect("value_changed", Callable(self, "_on_mastervol_changed"))
	music_vol_slider.connect("value_changed", Callable(self, "_on_musicvol_changed"))
	env_vol_slider.connect("value_changed", Callable(self, "_on_envvol_changed"))
	
	resume_button.connect("pressed", Callable(self, "_on_resume_pressed"))
	quit_button.connect("pressed", Callable(self, "_on_quit_pressed"))

func _onfovreset_pressed():
	var s = GameSettings.settings
	fov_slider.value = s.default_fov
	fov_reset_btn.visible = false
	GameSettings.save_settings()

func _on_sensReset_pressed():
	var s = GameSettings.settings
	sensitivity_slider.value = s.default_sensitivity
	sens_reset_btn.visible = false
	GameSettings.save_settings()

func _on_envvol_changed(value:float):
	GameSettings.settings.envVol = value
	GameSettings.save_settings()
	env_vol_percentage_label.text = str(value) + " dB"
	AudioServer.set_bus_volume_db(envVol, value)
	
func _on_musicvol_changed(value:float):
	GameSettings.settings.musicVol = value
	GameSettings.save_settings()
	music_vol_percentage_label.text = str(value) + " dB"
	AudioServer.set_bus_volume_db(musicVol, value)
	
func _on_mastervol_changed(value:float):
	GameSettings.settings.masterVol = value
	GameSettings.save_settings()
	master_vol_percentage_label.text = str(value) + " dB"
	AudioServer.set_bus_volume_db(mastVol, value)

func _on_sensitivity_changed(value:float):
	GameSettings.settings.mouse_sensitivity = value
	GameSettings.save_settings()
	sensitivity_percentage_label.text = str(value) + " %"
	if value > default_sens or value < default_sens:
		sens_reset_btn.visible = true
	print("Updated mouse sensitivity:", value)

func _on_fov_changed(value:float):
	GameSettings.settings.base_fov = value
	GameSettings.save_settings()
	if value > default_fov or value < default_fov:
		fov_reset_btn.visible = true
	fov_percentage_label.text = str(value) + " %"
	
	print("Updated FOV:", value)

func show_menu():
	visible = true
	pause_tab.visible = true

func hide_menu():
	visible = false
	pause_tab.visible = false

func _on_resume_pressed():
	hide_menu()
	GameController._instance.toggle_pause()

func _on_quit_pressed():
	get_tree().quit()
