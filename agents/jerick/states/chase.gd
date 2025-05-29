extends LimboState

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@export var movement_speed: float = 3.0
var state_machine: LimboHSM
var distance_max: float = 9.0
var distance_min: float = 1.5
var target: Player


func _ready() -> void:
	state_machine = get_root()

func _enter() -> void:
	target = owner.bt_player.blackboard.get_var(owner.target_var)

	animation_player.play("Walk")

func _update(_delta: float):
	owner.look_at_target(target)

	var direction = (target.global_position - agent.global_position).normalized()
	direction.y = 0

	var distance = owner.global_position.distance_to(target.global_position)

	if distance <= distance_max and distance >= distance_min:
		owner.velocity = Vector3(direction.x, 0, direction.z) * movement_speed
	else:
		owner.velocity = Vector3.ZERO