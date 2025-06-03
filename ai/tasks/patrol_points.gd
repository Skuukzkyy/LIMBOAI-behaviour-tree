class_name BTPatrolPoints
extends BTAction

## Movement speed when navigating to patrol points
@export var movement_speed: float = 5.0
## How close agent needs to be to consider the point reached
@export var tolerance: float = 1.0
## Name of the patrol points array variable in the blackboard
@export var patrol_points_var: StringName = &"patrol_points"
## Name of the current patrol index variable in the blackboard
@export var current_index_var: StringName = &"current_patrol_index"
## Name of the enemy nearby variable in the blackboard
@export var is_enemy_nearby_var: StringName = &"is_enemy_nearby"
## If true, the agent will face the direction it's moving
@export var look_at_target: bool = true

var _navigation_agent: NavigationAgent3D

func _setup() -> void:
	# Get the NavigationAgent3D from the agent
	_navigation_agent = agent.get_node("NavigationAgent3D") if agent.has_node("NavigationAgent3D") else null
	if not _navigation_agent:
		push_error("BTPatrolPoints: NavigationAgent3D not found on agent")
		return

	# Verify blackboard has required variables
	if not blackboard.has_var(patrol_points_var):
		push_error("BTPatrolPoints: Patrol points variable not found in blackboard")
		return

	if not blackboard.has_var(current_index_var):
		push_warning("BTPatrolPoints: Current index variable not found in blackboard. Initializing to 0.")
		blackboard.set_var(current_index_var, 0)


func _tick(_delta: float) -> Status:
	# Check if enemy is nearby - if so, interrupt patrol immediately
	if blackboard.get_var(is_enemy_nearby_var, false, false):
		# Force agent to stop moving when interrupted
		agent.velocity = Vector3.ZERO
		# Immediately abort the task
		return FAILURE

	if not _navigation_agent:
		return FAILURE

	var patrol_positions = blackboard.get_var(patrol_points_var, [])
	if patrol_positions.size() == 0:
		return FAILURE

	var current_index = blackboard.get_var(current_index_var, 0)

	# Ensure index is within bounds
	if current_index >= patrol_positions.size():
		current_index = 0

	var target_position = patrol_positions[current_index]
	_navigation_agent.target_position = target_position

	if _navigation_agent.is_navigation_finished():
		# Reached current point, move to next point
		current_index = (current_index + 1) % patrol_positions.size()
		blackboard.set_var(current_index_var, current_index)
		return SUCCESS

	# Navigate toward target
	var next_path_position: Vector3 = _navigation_agent.get_next_path_position()
	var direction = (next_path_position - agent.global_position).normalized()

	# Set agent velocity
	var velocity = direction * movement_speed
	velocity.y = agent.velocity.y
	agent.velocity = velocity

	# Optional: Make the agent face the direction it's moving
	if look_at_target:
		var look_target = Vector3(next_path_position.x, agent.global_position.y, next_path_position.z)
		if !agent.global_position.is_equal_approx(look_target):
			agent.look_at(look_target, Vector3.UP)
			agent.rotate_y(PI)

	return RUNNING


func _enter() -> void:
	# Reset the navigation agent's state when entering patrol task
	if _navigation_agent:
		_navigation_agent.target_position = agent.global_position
		_navigation_agent.velocity = Vector3.ZERO
		# Force recalculation of path
		_navigation_agent.get_final_position()


# Called when exiting this task to clean up
func _exit() -> void:
	agent.velocity = Vector3.ZERO

	# Clear navigation path when exiting
	if _navigation_agent:
		_navigation_agent.target_position = agent.global_position
