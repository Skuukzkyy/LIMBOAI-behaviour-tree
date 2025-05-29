extends CharacterBody3D

@onready var bt_player: BTPlayer = $BTPlayer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var state_machine: LimboHSM = $LimboHSM
@onready var idle_state: LimboState = $LimboHSM/Idle
@onready var alert_state: LimboState = $LimboHSM/Alert
@onready var chase_state: LimboState = $LimboHSM/Chase
@onready var attack_state: LimboState = $LimboHSM/Attack
@onready var interact_state: LimboState = $LimboHSM/Interact

var target_var: StringName = "target"
var is_interacting: bool = false


func _ready() -> void:
	_initialize_state_machine()
	state_machine.active_state_changed.connect(_on_active_state_changed)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func look_at_target(target: Player) -> void:
	# Look at the target
	var target_position = target.global_position
	target_position.y = global_position.y
	look_at(target_position)
	rotate_y(PI)

func interact() -> void:
	is_interacting = true

# SIGNALS
func _on_enemy_detector_body_entered(body:Node3D) -> void:
	if body is Player:
		bt_player.blackboard.set_var(target_var, body)

func _on_enemy_detector_body_exited(body:Node3D) -> void:
	if body is Player:
		bt_player.blackboard.set_var(target_var, null)

func _on_active_state_changed(current_state: LimboState, _previous_state: LimboState) -> void:
	print("STATE CHANGED FROM ", _previous_state.name, " TO ", current_state.name)

func _initialize_state_machine() -> void:
	state_machine.initial_state = idle_state
	state_machine.initialize(self)
	state_machine.set_active(true)

	state_machine.add_transition(state_machine.ANYSTATE, idle_state, "to_idle")
	state_machine.add_transition(state_machine.ANYSTATE, alert_state, "to_alert")
	state_machine.add_transition(state_machine.ANYSTATE, chase_state, "to_chase")
	state_machine.add_transition(state_machine.ANYSTATE, attack_state, "to_attack")
	state_machine.add_transition(state_machine.ANYSTATE, interact_state, "to_interact")
