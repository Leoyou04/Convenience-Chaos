extends TextureRect

var player: CharacterBody3D
var hide_timer: float = 0.0
var hide_delay: float = 0.3  # Time to hide indicator after player stops moving

func _ready() -> void:
	# Hide by default until movement is detected.
	visible = false
	_resolve_player()

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		_resolve_player()
		if not player:
			return

	# Ignore vertical speed so jumping/falling doesn't trigger the UI indicator.
	var planar_speed := Vector2(player.velocity.x, player.velocity.z).length()

	if planar_speed > 0.1:
		visible = true
		hide_timer = 0.0
	else:
		hide_timer += delta
		if hide_timer >= hide_delay:
			visible = false

func _resolve_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	if players[0] is CharacterBody3D:
		player = players[0]
