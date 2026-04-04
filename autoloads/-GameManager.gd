extends Node

enum State { MENU, PLAYING, PAUSED, GAME_OVER, WIN }

var current_state: int = State.MENU
var night_timer: float = 0.0
var night_duration: float = 360.0

func _process(delta):
	if current_state == State.PLAYING:
		night_timer += delta
		if night_timer >= night_duration:
			set_state(State.GAME_OVER)

func set_state(new_state: int):
	current_state = new_state

func start_game():
	night_timer = 0.0
	set_state(State.PLAYING)

func get_time_remaining() -> float:
	return max(0.0, night_duration - night_timer)
