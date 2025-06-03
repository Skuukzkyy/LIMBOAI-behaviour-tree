extends Label

# Optional variables for customization
@export var show_prefix: bool = true
@export var prefix: String = "State: "
@export var default_text: String = "Idle"

# Colors for different states (optional)
@export var idle_color: Color = Color.WHITE
@export var patrol_color: Color = Color.GREEN
@export var alert_color: Color = Color.YELLOW
@export var chase_color: Color = Color.RED
@export var roll_color: Color = Color.PURPLE

func _ready() -> void:
	# Set default text
	if default_text:
		change_text(default_text)


# Called from behavior tree to update the label
func change_text(new_text: String) -> void:
	# Set the label text with optional prefix
	text = prefix + new_text if show_prefix else new_text

	# Change color based on state (if desired)
	match new_text:
		"Idle":
			modulate = idle_color
		"Patrol":
			modulate = patrol_color
		"Alert":
			modulate = alert_color
		"Chase":
			modulate = chase_color
		"Out of Range":
			modulate = Color.AQUA
		"Roll":
			modulate = roll_color
