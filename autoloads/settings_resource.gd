extends Resource
class_name SettingsResource

@export_category("Player Settings")
## Controls the default mouse sensitivity for the player.
@export_range(10.0, 50.0, 1.0) var mouse_sensitivity :float = default_sensitivity
## Controls the default field of view for the player.
@export_range(20, 110.0, 1.0) var base_fov := default_fov
## Controls the default player speed for walking
@export_range(1.0, 10.0, 1.0) var player_speed := default_player_speed
## Controls the sprint speed of player
@export_range(1.0, 10.0, 1.0) var player_sprint_speed := default_player_sprint_speed
## Controls the default player jump velocity for the player.
@export_range(1.0, 10.0, 1.0) var player_jump_velocity := default_player_jump_velocity
## Controls the default leaning angle; degrees to tilt
@export_range(0.0, 10.0, 1.0) var lean_angle := default_lean_angle        # degrees to tilt
## Controls how far the camera shifts sideways
@export var lean_distance: float= default_lean_dist     # how far the camera shifts sideways
## Controls how fast the lean happens
@export_range(0.0, 25.0, 1.0) var lean_speed := default_lean_speed        # how fast lean happens
## Controls the return speed; slower feels more natural
@export_range(0.0, 10.0, 1.0) var return_speed := default_lean_return_speed       # slower return feels natural

# INTERACTION 
@export var interaction_distance: float = 3.0


## CROUCHING
@export var crouch_height: float = 1.0
@export var standing_height: float = 2.0
@export var crouch_speed: float = 0.5
@export var crouch_transition_time: float = 0.2




@export_category("Game Settings")
## Starting level for the player
@export var Starting_Level: PackedScene

@export_category("Audio Settings")
## Controls the master volume; Master bus
@export_range(-20, 0.0, 1.0) var masterVol := default_mastVol
## Controls the Environment volume; Make sure there is an Audio Bus named "Environment"
@export_range(-20, 0.0, 1.0) var envVol := default_envVol
## Controls the Music volume; Make sure there is an Audio Bus named "Music"
@export_range(-20, 0.0, 1.0) var musicVol := default_musicVol

@export var footstep_sounds: Array[FootstepData]=[]


var sprint_fov := base_fov + 10
var fov_smooth_speed := 3
const default_lean_angle = 10
const default_lean_dist = 0.25
const default_lean_speed = 10
const default_lean_return_speed = 4
const default_player_jump_velocity = 3
const default_player_sprint_speed = 3
const default_player_speed = 2
const default_sensitivity := 15
const default_fov := 75
const default_mastVol = 0
const default_envVol = 0
const default_musicVol = 0
