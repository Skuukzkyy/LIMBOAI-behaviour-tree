@tool
class_name BTPlayAnimationOnce extends BTAction

## Name of the animation to play
@export var animation_name: StringName = &""
## Optional blackboard variable to check for validity
@export var condition_var: StringName = &""
## If false when using condition_var, the task fails
@export var condition_value: BBVariant
@export var animation_player_path: NodePath

var _animation_started: bool = false

func _generate_name() -> String:
	return "PlayAnimation (%s) while %s is %s" % [animation_name,
		LimboUtility.decorate_var(condition_var), condition_value]

func _setup() -> void:
	if animation_name.is_empty():
		push_error("BTPlayAnimation: No animation name specified")

func _enter() -> void:
	_animation_started = false

func _tick(_delta: float) -> Status:
	# Check condition
	if not condition_var.is_empty() and blackboard.has_var(condition_var):
		# Get the value stored in the blackboard
		var blackboard_value = blackboard.get_var(condition_var)

		# Compare as strings to handle BBVariant comparison
		if str(condition_value) != str(blackboard_value):
			_animation_started = false
			return FAILURE

	# Check for animation player
	var animation_player = agent.get_node_or_null(animation_player_path)
	if not animation_player:
		push_error("BTPlayAnimation: No AnimationPlayer found on agent")
		return FAILURE

	# Start animation if not already started
	if not _animation_started:
		animation_player.play(animation_name)
		_animation_started = true

	# Always return RUNNING to keep this task active
	return RUNNING

func _exit() -> void:
	# Reset state when exiting
	_animation_started = false
