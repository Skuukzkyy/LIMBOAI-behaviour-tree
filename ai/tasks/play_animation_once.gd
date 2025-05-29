extends BTAction

@export var animation_name: String = "Punch_Enter"
@export var target_var: StringName = &"target"
var has_started_animation := false

func _enter() -> void:
    has_started_animation = false

func _tick(_delta: float) -> Status:
    # Check if target is still valid
    if not blackboard.has_var(target_var) or not blackboard.get_var(target_var):
        has_started_animation = false
        return Status.FAILURE
    
    # Check if is_enemy_nearby is still true
    if agent is CharacterBody3D and not agent.is_enemy_nearby:
        has_started_animation = false
        return Status.FAILURE
    
    if not has_started_animation:
        agent.animation_player.play(animation_name)
        has_started_animation = true
    
    # Return RUNNING to stay in this state
    return Status.RUNNING