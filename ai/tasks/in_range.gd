@tool
extends BTCondition
## InRange condition checks if the agent is within a range of target,
## defined by [member distance_min] and [member distance_max]. [br]
## Returns [code]SUCCESS[/code] if the agent is within the given range;
## otherwise, returns [code]FAILURE[/code].

## Minimum distance to target.
@export var distance_min: float

## Maximum distance to target.
@export var distance_max: float

## Blackboard variable that holds the target.
@export var target_var: StringName = &"target"


# Called to generate a display name for the task.
func _generate_name() -> String:
	return "InRange (%d, %d) of %s" % [distance_min, distance_max,
		LimboUtility.decorate_var(target_var)]

# Called when the task is executed.
func _tick(_delta: float) -> Status:
	if not blackboard.has_var(target_var):
		return Status.FAILURE

	var target: Player = blackboard.get_var(target_var, null)

	if not target or target is not Player:
		return Status.FAILURE

	var distance = agent.global_position.distance_to(target.global_position)

	return Status.SUCCESS if distance <= distance_max and distance >= distance_min else Status.FAILURE
