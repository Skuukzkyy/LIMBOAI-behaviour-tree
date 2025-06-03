@tool
class_name BTLookAt
extends BTAction
## Makes the agent look at a target using the built-in look_at method
##
## This task makes the agent face a target (either a Node3D or Vector3 position)
## using Godot's built-in look_at method. It can optionally smooth the rotation
## with interpolation for more natural-looking turns.

## Target to look at (Node3D or Vector3, gets from blackboard)
@export var target_blackboard_key: String = "target"

## How fast the agent rotates to face target (interpolation factor)
@export var rotation_speed: float = 5.0

## Whether to continue running while looking at target
@export var keep_looking: bool = true

# Private variables
var _target_position: Vector3 = Vector3.ZERO


func _tick(_delta: float) -> Status:
	# Get target from blackboard
	var target = blackboard.get_var(target_blackboard_key)
	if target == null:
		return Status.FAILURE

	# Handle different target types
	if target is Vector3:
		_target_position = target
	elif target is Node3D:
		_target_position = target.global_position
	else:
		push_error("BTLookAt: Unsupported target type. Expected Vector3 or Node3D.")
		return Status.FAILURE

	# _target_position.y = agent.global_position.y
	agent.look_at(_target_position, Vector3.UP)
	agent.rotate_y(PI)

	# Return success if we don't need to keep looking
	if not keep_looking:
		return Status.SUCCESS

	return Status.RUNNING
