extends RayCast3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and is_colliding():
		var target = get_collider()

		if target is CharacterBody3D and target.has_method("interact"):
			target.call("interact")
