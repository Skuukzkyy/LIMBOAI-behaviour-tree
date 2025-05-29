extends LimboState

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _enter() -> void:
	owner.velocity = Vector3.ZERO

	animation_player.play("Idle")