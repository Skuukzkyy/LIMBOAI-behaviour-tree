extends BTAction

var duration: float = 0
var target_duration: float = 3.0
var direction: Vector3


func _enter() -> void:
	agent.look_at(agent.global_position + Vector3.FORWARD, Vector3.UP)
	duration = 0

func _tick(_delta: float) -> Status:
	duration += _delta
	direction = Vector3.RIGHT

	agent.fly_away(duration * 2)

	if duration >= target_duration:
		return Status.SUCCESS

	return Status.RUNNING
