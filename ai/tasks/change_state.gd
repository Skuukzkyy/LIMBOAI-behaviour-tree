extends BTAction

@export var state_event_name: StringName


func _tick(_delta: float) -> Status:
	agent.state_machine.dispatch(state_event_name)

	return Status.SUCCESS