extends CharacterBody3D

@onready var bt_player: BTPlayer = $BTPlayer
var fly_direction: Vector3


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func fly_away(duration: float) -> void:
	# Use the fly_direction that was set when player was detected
	# Add upward velocity component for a more natural escape trajectory
	velocity = (Vector3.UP * duration) * 5 + fly_direction * 10


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		# Calculate direction away from the player
		var direction_to_player = body.global_position - global_position
		# Reverse the direction to get away from player
		fly_direction = -direction_to_player.normalized()
		# Zero out the Y component to keep flight mostly horizontal
		fly_direction.y = 0
		fly_direction = fly_direction.normalized()

		# Set the bird state to scared
		bt_player.blackboard.set_var("state", "scared")
