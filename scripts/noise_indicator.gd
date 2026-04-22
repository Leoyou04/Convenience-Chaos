extends Sprite3D

var player: Node3D
var hide_timer: float = 0.0
var hide_delay: float = 0.3  # Time to hide sprite after player stops moving

func _ready() -> void:
	# Hide the sprite by default
	visible = false
	
	# Get reference to the player (parent node)
	player = get_parent()

func _process(delta: float) -> void:
	if not player:
		return
	
	# Check if player is moving (has velocity)
	var player_velocity = player.velocity if player.has_meta("velocity") or player is CharacterBody3D else Vector3.ZERO
	
	if player_velocity.length() > 0.1:
		# Player is moving, show the sprite
		visible = true
		hide_timer = 0.0
	else:
		# Player is not moving, start countdown to hide
		hide_timer += delta
		if hide_timer >= hide_delay:
			visible = false
