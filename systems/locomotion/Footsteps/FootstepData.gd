extends Resource
class_name FootstepData

## The name or ID of the surface material (Matches what's set in meshes or floor nodes)
@export var material_name: String = ""

## The audio stream to play when stepping on this material
@export var footstep_sound: AudioStream
