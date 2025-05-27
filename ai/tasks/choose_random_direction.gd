extends BTAction

## Picks a random position inside a Path3D area
##
## Requires a Path3D node with a PathFollow3D child in the tree.
## The random position will be set to the blackboard key specified.

## Path3D node to get random positions from
var path_node_path: NodePath = "../Path3D"
## Blackboard key to store the resulting random position
var target_position_key: String = "bird_random_pos"
var min_progress: float = 0.0
var max_progress: float = 1.0
var path: Path3D
var path_follow: PathFollow3D


func _setup() -> void:
	path = agent.get_node_or_null(path_node_path)
	if not path is Path3D:
		push_error("Node at %s is not a Path3D" % path_node_path)
		return

	for child in path.get_children():
		if child is PathFollow3D:
			path_follow = child
			break

	if path_follow == null:
		push_error("PathFollow3D child not found in %s" % path_node_path)
		return

func _tick(_delta: float) -> Status:
	if not path or not path_follow:
		return Status.FAILURE

	path_follow.progress_ratio = randf_range(min_progress, max_progress)

	# Get the global position at this point
	var random_position = path_follow.global_position

	# Store the position in the blackboard
	blackboard.set_var(target_position_key, random_position)

	return Status.SUCCESS
