extends BTAction

var target_position_key: String = "bird_random_pos"

func _tick(_delta: float) -> Status:
	var target_pos: Vector3 = blackboard.get_var(target_position_key)
	if not target_pos:
		return Status.FAILURE

	var direction = target_pos - agent.global_position
	direction.y = 0

	if direction.length() < 0.001:
		return Status.SUCCESS

	# Make agent face that direction
	agent.look_at(agent.global_position + direction, Vector3.UP)

	return Status.SUCCESS