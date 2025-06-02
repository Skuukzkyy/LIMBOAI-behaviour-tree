extends Node3D

var last_valid_movement_area_var: StringName = "last_valid_movement_area"
var patrol_points_var: StringName = "patrol_points"
var current_patrol_index_var: StringName = "current_patrol_index"

@onready var movement_area_shape: CollisionShape3D = $JerickMovementArea/CollisionShape3D


func _on_jerick_movement_area_body_entered(body: JerickNpc) -> void:
	if body is JerickNpc and body.has_method("set_is_on_movement_area"):
		body.set_is_on_movement_area(true)
		save_patrol_positions(body)


func _on_jerick_movement_area_body_exited(body: JerickNpc) -> void:
	if body is JerickNpc and body.has_method("set_is_on_movement_area"):
		var safe_position = offset_last_position(body.global_position)

		body.bt_player.blackboard.set_var(last_valid_movement_area_var, safe_position)
		body.set_is_on_movement_area(false)

func offset_last_position(npc_position: Vector3) -> Vector3:
	# Offset the position toward the center by a small amount (adjust this value as needed)
	var offset_amount = 5.0  # Units to offset inward

	var exit_pos = npc_position
	var direction_to_center = (movement_area_shape.global_position - exit_pos).normalized()
	var safe_position = exit_pos + (direction_to_center * offset_amount)
	# Store the offset position instead of the exact exit position
	return safe_position

func save_patrol_positions(body: JerickNpc) -> Array:
	var patrol_positions = []

	for point in body.patrol_points:
		patrol_positions.append(point.global_position)

	body.bt_player.blackboard.set_var(patrol_points_var, patrol_positions)
	body.bt_player.blackboard.set_var(current_patrol_index_var, 0)

	return patrol_positions