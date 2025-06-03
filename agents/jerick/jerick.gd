class_name JerickNpc extends CharacterBody3D

@onready var bt_player: BTPlayer = $BTPlayer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

@export var patrol_points: Array[Marker3D]
@export var speed: float = 5.0
@export var target_player_var: StringName = &"target_player"
@export var is_enemy_nearby_var: StringName = &"is_enemy_nearby"
@export var interact_animation: String = "Roll"
@export var interaction_cooldown: float = 1.5

var is_on_movement_area: bool = false
var _can_interact: bool = true
var _interaction_timer: float = 0.0


func _physics_process(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle interaction cooldown
	if not _can_interact:
		_interaction_timer -= delta
		if _interaction_timer <= 0:
			_can_interact = true

	move_and_slide()

func set_is_on_movement_area(value: bool) -> void:
	is_on_movement_area = value

func _on_enemy_detector_body_entered(body:Node3D) -> void:
	if body is Player:
		bt_player.blackboard.set_var(target_player_var, body)
		bt_player.blackboard.set_var(is_enemy_nearby_var, true)
		animation_player.play("Punch_Enter")

func _on_enemy_detector_body_exited(body:Node3D) -> void:
	if body is Player:
		bt_player.blackboard.erase_var(target_player_var)
		bt_player.blackboard.set_var(is_enemy_nearby_var, false)


# Called when player interacts with Jerick
func interact() -> void:
	if _can_interact:
		# Pause behavior tree execution
		bt_player.active = false

		# Play roll animation
		animation_player.play(interact_animation)

		# Start cooldown
		_can_interact = false
		$LabelCurrentBehavior.change_text("Roll")
		_interaction_timer = interaction_cooldown

		# Wait for animation to finish and then resume behavior tree
		await animation_player.animation_finished
		bt_player.active = true
