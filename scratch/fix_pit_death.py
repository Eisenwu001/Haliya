with open('scripts/main.gd', 'r', encoding='utf-8') as f:
    text = f.read()

target = """		# Water hazard / pit drop detection (falling off ground)
		if not is_transitioning and not is_player_dead:
			if player.global_position.y > 360.0:
				_on_player_died()

	# Continuous scan for enemies falling down the map / into pits
	if active_enemies.size() > 0:
		var enemies_to_kill: Array[Node] = []
		for e in active_enemies:
			if is_instance_valid(e) and not e.get("is_dead"):
				if e.global_position.y > 360.0:
					enemies_to_kill.append(e)"""

repl = """		# Water hazard / pit drop detection (falling off ground)
		var pit_death_y: float = current_level_height if current_level_height > 360.0 else 360.0
		if not is_transitioning and not is_player_dead:
			if player.global_position.y > pit_death_y:
				_on_player_died()

	# Continuous scan for enemies falling down the map / into pits
	if active_enemies.size() > 0:
		var enemies_to_kill: Array[Node] = []
		var enemy_pit_death_y: float = current_level_height if current_level_height > 360.0 else 360.0
		for e in active_enemies:
			if is_instance_valid(e) and not e.get("is_dead"):
				if e.global_position.y > enemy_pit_death_y:
					enemies_to_kill.append(e)"""

assert target in text, "Target string not found in main.gd!"
text = text.replace(target, repl)

with open('scripts/main.gd', 'w', encoding='utf-8', newline='\r\n') as f:
    f.write(text)

print('Updated main.gd with dynamic pit_death_y!')
