@tool
class_name BTNavigateToTarget
extends BTAction

## Movement speed when navigating to target
@export var movement_speed: float = 5.0
## How close agent needs to be to consider the target reached
@export var tolerance: float = 1.0
## Name of the target variable in the blackboard (should be a Node3D or Vector3)
@export var target_var: StringName = &"target_player"
## If true, the agent will face the direction it's moving
@export var look_at_target: bool = true
@export var navigation_agent_path: NodePath
## How many seconds to consider agent as stuck if position hasn't changed
@export var stuck_time_threshold: float = 1.5
## How much position must change to not be considered stuck
@export var stuck_distance_threshold: float = 0.1
## Maximum times to retry navigation when stuck before failing
@export var max_stuck_retries: int = 5
## Duration of sidestep maneuver in seconds
@export var sidestep_duration: float = 1.0

var _navigation_agent: NavigationAgent3D
var _last_position: Vector3 = Vector3.ZERO
var _stuck_timer: float = 0.0
var _stuck_retries: int = 0
var _last_target_position: Vector3 = Vector3.ZERO
var _is_sidestepping: bool = false
var _sidestep_timer: float = 0.0
var _sidestep_direction: Vector3 = Vector3.ZERO

func _generate_name() -> String:
	return "NavigateTo(%s, speed: %.1f)" % [
		LimboUtility.decorate_var(target_var),
		movement_speed
	]


func _setup() -> void:
	if not navigation_agent_path:
		push_error("BTNavigateToTarget: NavigationAgent3D not found on agent")
		return

	_navigation_agent = agent.get_node_or_null(navigation_agent_path)

	if not _navigation_agent or not _navigation_agent is NavigationAgent3D:
		push_error("BTNavigateToTarget: NavigationAgent3D not found on agent")
		return

	# Verify blackboard has required variables
	if not blackboard.has_var(target_var):
		push_error("BTNavigateToTarget: Target variable not found in blackboard")


func _tick(delta: float) -> Status:
	# Get the target from blackboard
	if not blackboard.has_var(target_var):
		return FAILURE
		
	var target = blackboard.get_var(target_var)
	var target_position: Vector3
	
	# Handle different target types
	if target is Vector3:
		target_position = target
	elif target is Node3D:
		target_position = target.global_position
	else:
		push_error("BTNavigateToTarget: Target is not a Vector3 or Node3D")
		return FAILURE
	
	# Check if target has moved significantly and reset navigation
	if _last_target_position != Vector3.ZERO and _last_target_position.distance_to(target_position) > tolerance * 2:
		_navigation_agent.target_position = target_position
		_last_target_position = target_position
		_stuck_timer = 0.0
	elif _last_target_position == Vector3.ZERO:
		_last_target_position = target_position
	
	# Check if we're already at the target
	var distance = agent.global_position.distance_to(target_position)
	if distance <= tolerance:
		return SUCCESS
		
	# If navigation is finished but we're not within tolerance,
	# it means we can't reach the target - restart navigation
	if _navigation_agent.is_navigation_finished():
		_navigation_agent.target_position = target_position
		
	# Handle sidestep maneuver if active
	if _is_sidestepping:
		_sidestep_timer += delta
		if _sidestep_timer >= sidestep_duration:
			# End sidestep
			_is_sidestepping = false
			_sidestep_timer = 0.0
			# Recalculate path after sidestep
			_navigation_agent.target_position = target_position
		else:
			# Continue sidestep movement
			var adjusted_velocity = _sidestep_direction * movement_speed
			adjusted_velocity.y = agent.velocity.y
			agent.velocity = adjusted_velocity
			return RUNNING
	
	# Check if agent is stuck
	var current_position = agent.global_position
	if current_position.distance_to(_last_position) < stuck_distance_threshold:
		_stuck_timer += delta
		if _stuck_timer >= stuck_time_threshold:
			_stuck_retries += 1
			
			if _stuck_retries > max_stuck_retries:
				push_warning("BTNavigateToTarget: Agent is stuck and exceeded retry limit")
				return FAILURE
			
			# Apply sidestep maneuver
			_start_sidestep(target_position)
			_stuck_timer = 0.0
			push_warning("BTNavigateToTarget: Agent appears stuck, trying sidestep")
	else:
		_stuck_timer = 0.0
		_last_position = current_position
		
	# Standard navigation
	var next_path_position = _navigation_agent.get_next_path_position()
	var direction = (next_path_position - agent.global_position).normalized()
	
	# Set agent velocity
	var velocity = direction * movement_speed
	velocity.y = agent.velocity.y  # Maintain Y velocity for gravity
	agent.velocity = velocity
	
	# Optional: Make the agent face the direction it's moving
	if look_at_target:
		var look_target = Vector3(next_path_position.x, agent.global_position.y, next_path_position.z)
		if !agent.global_position.is_equal_approx(look_target):
			agent.look_at(look_target, Vector3.UP)
			agent.rotate_y(PI)
	
	return RUNNING

func _enter() -> void:
	# Reset agent velocity
	agent.velocity = Vector3.ZERO
	
	# Reset navigation agent state to ensure fresh pathfinding
	if _navigation_agent:
		_navigation_agent.target_position = agent.global_position
		_navigation_agent.velocity = Vector3.ZERO
		# Force path recalculation on next update
		_navigation_agent.get_final_position()
	
	# Reset tracking variables
	_last_position = agent.global_position
	_stuck_timer = 0.0
	_stuck_retries = 0
	_last_target_position = Vector3.ZERO
	_is_sidestepping = false
	_sidestep_timer = 0.0

func _exit() -> void:
	# Stop the agent when exiting this task
	agent.velocity = Vector3.ZERO


func _start_sidestep(target_pos: Vector3) -> void:
	_is_sidestepping = true
	_sidestep_timer = 0.0
	
	# Calculate direction to target
	var dir_to_target = (target_pos - agent.global_position).normalized()
	
	# Choose a random unstuck strategy based on retry count
	var random_choice = randf()
	
	# First option: sidestep perpendicular (left/right) - 40% chance
	if random_choice < 0.4:
		# Create a perpendicular vector (simulate a cross product with UP)
		_sidestep_direction = Vector3(dir_to_target.z, 0, -dir_to_target.x).normalized()
		
		# Randomly choose between the two possible perpendicular directions
		if randf() > 0.5:
			_sidestep_direction = -_sidestep_direction
		
	# Second option: move backward away from target - 30% chance
	elif random_choice < 0.7:
		_sidestep_direction = -dir_to_target
		
	# Third option: move in a random direction - 30% chance
	else:
		# Generate a random horizontal direction
		var angle = randf() * TAU  # Random angle in radians (0 to 2π)
		_sidestep_direction = Vector3(cos(angle), 0, sin(angle)).normalized()
