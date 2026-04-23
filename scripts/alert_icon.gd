extends TextureRect

var alert_timer: float = 0.0
var alert_duration: float = 2.0  # Duration to show alert (seconds)
var is_alerted: bool = false

func _ready() -> void:
	# Hide by default
	visible = false

func _process(delta: float) -> void:
	if is_alerted:
		alert_timer += delta
		
		# Hide alert after duration expires
		if alert_timer >= alert_duration:
			is_alerted = false
			visible = false
			alert_timer = 0.0

func show_alert() -> void:
	"""Call this function to show the alert icon"""
	visible = true
	is_alerted = true
	alert_timer = 0.0

func hide_alert() -> void:
	"""Manually hide the alert icon"""
	visible = false
	is_alerted = false
	alert_timer = 0.0
