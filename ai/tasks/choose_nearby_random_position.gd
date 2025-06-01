@tool
extends BTAction

# Minimum distance to the desired position.
@export var range_min: float = 3.0
# Maximum distance to the desired position.
@export var range_max: float = 8.0
# Blackboard variable that will be used to store the desired position.
@export var position_var: StringName = &"random_position"
# Height offset for the random position (useful for flying or underwater agents)
@export var height_offset: float = 0.0
# Maximum attempts to find a valid position (avoids infinite loops)
@export var max_attempts: int = 10

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "SelectRandomNearbyPos range: [%s, %s] ➜%s" % [
		range_min, range_max,
		LimboUtility.decorate_var(position_var)]

# Called each time this task is ticked (aka executed).
func _tick(_delta: float) -> Status:
	# Get agent's current position as a starting reference
	var agent_pos: Vector3 = agent.global_position
	
	# Generate random position
	var pos: Vector3 = _get_random_nearby_position(agent_pos)
	
	# Store the resulting position in the blackboard
	blackboard.set_var(position_var, pos)
	
	# Print debug info
	
	return SUCCESS

# Generates a random position near the agent within the specified range
func _get_random_nearby_position(origin: Vector3) -> Vector3:
	var attempts = 0
	var random_pos = origin
	
	while attempts < max_attempts:
		# Generate random angle (in radians)
		var angle = randf_range(0, PI * 2.0)
		
		# Generate random distance between min and max range
		var distance = randf_range(range_min, range_max)
		
		# Calculate position using polar coordinates (on XZ plane)
		var x_offset = cos(angle) * distance
		var z_offset = sin(angle) * distance
		
		# Create the new position
		random_pos = Vector3(
			origin.x + x_offset,
			origin.y + height_offset,  # Use height offset for Y
			origin.z + z_offset
		)
		
		# In a full implementation, you might want to do a navigation check here
		# to ensure the position is reachable, or do a raycast to ensure it's 
		# on walkable ground
		
		# For now, we'll just accept this position and return it immediately
		# No need to continue the loop since we found a valid position
		return random_pos
		
		# Note: The code below is unreachable due to the return statement above
		# It's kept here for reference in case we implement validation logic later
		# If we add position validation later, we would remove the return statement above
		# and only return a position that passes validation checks
		#attempts += 1
	
	# If we couldn't find a valid position after max attempts,
	# just return the original position with a small random offset
	# Note: This is currently unreachable due to the design, but kept as fallback
	return origin + Vector3(randf_range(-1, 1), height_offset, randf_range(-1, 1))
