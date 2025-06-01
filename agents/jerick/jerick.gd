class_name JerickNpc extends CharacterBody3D

@onready var bt_player: BTPlayer = $BTPlayer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

@export var speed: float = 5.0

@export var is_on_movement_area: bool = false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# navigation_agent.target_position = target_location.global_position

	# var direction = (navigation_agent.get_next_path_position() - global_position).normalized()
	# velocity = velocity.lerp(direction * speed , 10 * delta)

	move_and_slide()

func set_is_on_movement_area(value: bool) -> void:
	is_on_movement_area = value