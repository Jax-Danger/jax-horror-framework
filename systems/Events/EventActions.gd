extends Resource
class_name EventActions

## (Optional) The node that will receive the callback when this event triggers.
## Leave empty to skip calling a method.
@export var target_path: NodePath
## (Optional) The name of the method on the target node that will be called when triggered.
## Leave empty if you don't want to call any function.
@export var target_method: String = ""
## (Optional) Argument(s) for the target method if used.
@export var arguments: Array = []
## Delay for events
@export var delay := 0.5
