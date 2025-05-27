extends BTAction

var min_duration: float = 2.0
var max_duration: float = 4.0
var min_speed: float = .02
var max_speed: float = 1.0

var duration: float = 0
var target_duration: float
var current_speed: float

func _enter() -> void:
    duration = 0
    target_duration = randf_range(min_duration, max_duration)
    current_speed = randf_range(min_speed, max_speed)

func _tick(delta: float) -> Status:
    duration += delta
    
    # Move forward
    agent.translate(Vector3.FORWARD * current_speed * delta)
    
    # Check if we've moved for long enough
    if duration >= target_duration:
        return Status.SUCCESS
    
    return Status.RUNNING