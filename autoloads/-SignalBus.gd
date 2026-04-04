extends Node

signal game_state_changed(new_state)
signal objective_completed(objective_id)
signal all_objectives_completed
signal player_caught
signal distraction_thrown(position)
signal noise_level_changed(level)
