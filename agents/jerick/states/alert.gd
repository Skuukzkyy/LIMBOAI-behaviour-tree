extends LimboState

@onready var animation_player: AnimationPlayer = %AnimationPlayer
var state_machine: LimboHSM
var target: Player


func _ready() -> void:
	state_machine = get_root()

func _enter() -> void:
	target = owner.bt_player.blackboard.get_var(owner.target_var)
	owner.velocity = Vector3.ZERO

	animation_player.play("Punch_Enter")

func _update(_delta: float):
	owner.look_at_target(target)