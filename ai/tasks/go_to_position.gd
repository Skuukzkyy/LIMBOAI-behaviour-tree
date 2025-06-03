@tool
extends BTAction

## Blackboard variable that stores the target position (Vector3)
@export var target_position_var := &"random_position"

## Movement speed in units per second
@export var movement_speed := 3.0

## How close should the agent be to the target position to return SUCCESS
@export var tolerance := 0.5

## If true, the agent will look at the target position while moving
@export var look_at_target := true


func _generate_name() -> String:
	return "GoToPosition %s (speed: %s, tolerance: %s)" % [
		LimboUtility.decorate_var(target_position_var),
		str(movement_speed),
		str(tolerance)]

# Called each time this task is ticked (executed).
func _tick(_delta: float) -> Status:
	# Check if the target position variable exists
	if not blackboard.has_var(target_position_var):
		push_error("GoToPosition: Target position variable '", target_position_var, "' not found in blackboard")
		return Status.FAILURE
	
	# Get the target position
	var target_pos = blackboard.get_var(target_position_var)
	
	if target_pos is CharacterBody3D:
		target_pos = target_pos.global_position

	# Make sure target_pos is a Vector3
	if not target_pos is Vector3:
		push_error("GoToPosition: Target position is not a Vector3")
		return Status.FAILURE
	
	# Calculate distance to target
	var agent_pos = agent.global_position
	var distance = agent_pos.distance_to(target_pos)
	
	# If within tolerance, we've reached the target
	if distance <= tolerance:
		return Status.SUCCESS
	
	# Calculate direction to target
	var direction = (target_pos - agent_pos).normalized()
	
	# Look at target if enabled (while preserving Y rotation)
	if look_at_target and agent is Node3D:
		var look_target = target_pos
		look_target.y = agent_pos.y
		agent.look_at(look_target)
		agent.rotate_y(PI)
	
	# Apply movement (for CharacterBody3D)
	if agent is CharacterBody3D:
		# Calculate velocity - maintain y velocity for gravity
		var velocity = agent.velocity
		velocity.x = direction.x * movement_speed
		velocity.z = direction.z * movement_speed
		agent.velocity = velocity

	return Status.RUNNING

func _exit() -> void:
	if agent is CharacterBody3D:
		var velocity = agent.velocity
		velocity.x = 0.0
		velocity.z = 0.0
		agent.velocity = velocity
