import sys

with open("scripts/main.gd", "r", encoding="utf-8") as f:
    main_content = f.read()

nl = "\r\n" if "\r\n" in main_content else "\n"
main_content = main_content.replace("\r\n", "\n")

# 1. Header scripts & vars
target1 = 'const CaveAssetsScript = preload("res://scripts/cave_assets.gd")\n'
repl1 = """const CaveAssetsScript = preload("res://scripts/cave_assets.gd")
const UpgradeSelectUIScript = preload("res://scripts/upgrade_select_ui.gd")
const GameOverUIScript = preload("res://scripts/game_over_ui.gd")
var upgrade_select_ui: UpgradeSelectUI
var game_over_ui: GameOverUI
"""
assert target1 in main_content, "target1 not found"
main_content = main_content.replace(target1, repl1, 1)

# 2. _ready init_run
target2 = "func _ready() -> void:\n"
repl2 = """func _ready() -> void:
	UpgradeManager.init_run()
"""
assert target2 in main_content, "target2 not found"
main_content = main_content.replace(target2, repl2, 1)

# 3. setup_player stats sync
target3 = "player.damage_taken.connect(_on_player_damage_taken)\n"
repl3 = """player.damage_taken.connect(_on_player_damage_taken)
	UpgradeManager.sync_player_stats(player)
"""
assert target3 in main_content, "target3 not found"
main_content = main_content.replace(target3, repl3, 1)

# 4. setup_ui add upgrade_select_ui and game_over_ui
target4 = "setup_boss_hud()\n"
repl4 = """setup_boss_hud()

	upgrade_select_ui = UpgradeSelectUIScript.new()
	upgrade_select_ui.name = "UpgradeSelectUI"
	add_child(upgrade_select_ui)
	upgrade_select_ui.upgrade_selected.connect(_on_upgrade_selected)

	game_over_ui = GameOverUIScript.new()
	game_over_ui.name = "GameOverUI"
	add_child(game_over_ui)
	game_over_ui.restart_run_requested.connect(_on_restart_run_requested)
	game_over_ui.return_to_title_requested.connect(_on_return_to_title_requested)
"""
assert target4 in main_content, "target4 not found"
main_content = main_content.replace(target4, repl4, 1)

# 5. spawn_level_enemies difficulty scaling & extra horde spawns
target5 = """	if active_enemies.is_empty():
		unlock_exit_path()
	else:
		setup_exit_barrier()"""
repl5 = """	# Apply Roguelite Difficulty & Escalation Scaling
	var hp_mult = UpgradeManager.get_enemy_hp_multiplier()
	var spd_mult = UpgradeManager.get_enemy_speed_multiplier()
	var elite_rate = UpgradeManager.get_elite_chance()
	
	for enemy in active_enemies:
		if is_instance_valid(enemy) and not enemy.is_in_group("miniboss") and not enemy.is_in_group("boss"):
			var is_elite = (randf() < elite_rate)
			if enemy.has_method("apply_difficulty_scaling"):
				enemy.apply_difficulty_scaling(hp_mult, spd_mult, is_elite)

	# Dynamic Horde Spawning: Sprinkle extra patrol monsters across the 5120px terrain
	var extra_count = UpgradeManager.get_extra_spawn_count()
	if extra_count > 0 and current_level_idx < 12:
		_spawn_escalation_reinforcements(extra_count, hp_mult, spd_mult, elite_rate)

	if active_enemies.is_empty():
		unlock_exit_path()
	else:
		setup_exit_barrier()"""
assert target5 in main_content, "target5 not found"
main_content = main_content.replace(target5, repl5, 1)

# 6. Add _spawn_escalation_reinforcements
extra_spawn_fn = """
func _spawn_escalation_reinforcements(count: int, hp_mult: float, spd_mult: float, elite_rate: float) -> void:
	var cur_theme = LEVELS_DATA[current_level_idx].get("theme", "")
	var target_container = current_level_instance.find_child("Enemies", true, false) if current_level_instance else enemies_container
	if not target_container:
		target_container = enemies_container

	var step = 3200.0 / float(count + 1)
	for i in range(count):
		var spawn_x = 1100.0 + (i + 1) * step + randf_range(-80.0, 80.0)
		var spawn_pos = Vector2(spawn_x, 260.0)
		var enemy: CharacterBody2D = null

		if cur_theme == "Rice Field":
			var FarmerClass = preload("res://scripts/corrupted_farmer.gd")
			enemy = CharacterBody2D.new()
			enemy.set_script(FarmerClass)
		elif cur_theme == "Cave":
			enemy = SkeletonScript.new()
		else:
			enemy = AswangScript.new()

		enemy.global_position = spawn_pos
		enemy.add_to_group("enemies")
		if enemy.has_signal("aswang_died"):
			enemy.connect("aswang_died", Callable(self, "_on_aswang_died"))
		if enemy.has_signal("skeleton_died"):
			enemy.connect("skeleton_died", Callable(self, "_on_skeleton_died"))
		if enemy.has_signal("farmer_died"):
			enemy.connect("farmer_died", Callable(self, "_on_aswang_died"))

		var is_elite = (randf() < elite_rate)
		if enemy.has_method("apply_difficulty_scaling"):
			enemy.apply_difficulty_scaling(hp_mult, spd_mult, is_elite)

		target_container.add_child(enemy)
		active_enemies.append(enemy)
"""
main_content += extra_spawn_fn

# 7. Upgrade selection in _on_fade_out_complete
target7 = """func _on_fade_out_complete() -> void:
	# Check if all levels completed
	if current_level_idx >= LEVELS_DATA.size() - 1:
		trigger_win()
		var tween = create_tween()
		tween.tween_property(fade_overlay, "color:a", 0.0, 0.50)
		return

	# Advance to next level
	current_level_idx += 1
	load_current_level()
	spawn_level_enemies()

	# Reposition player to spawn point and restore full health & stamina
	if player:
		player.global_position = SPAWN_POS
		player.velocity = Vector2.ZERO
		last_player_x = SPAWN_POS.x
		if player.has_method("reset_combat_state"):
			player.reset_combat_state()
		camera.global_position = Vector2(clamp(SPAWN_POS.x, 320.0, current_level_width - 320.0), 180.0)

	# Fade in from black over 0.5s
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, 0.50)
	tween.tween_callback(Callable(self, "_on_fade_in_complete"))"""

repl7 = """func _on_fade_out_complete() -> void:
	# Check if all levels completed
	if current_level_idx >= LEVELS_DATA.size() - 1:
		trigger_win()
		var tween = create_tween()
		tween.tween_property(fade_overlay, "color:a", 0.0, 0.50)
		return

	# Show Upgrade Selection Shrine
	var draft = UpgradeManager.draft_upgrades(3)
	if not draft.is_empty() and is_instance_valid(upgrade_select_ui):
		upgrade_select_ui.display_draft(draft, UpgradeManager.current_tier)
	else:
		_proceed_to_next_level()


func _on_upgrade_selected(upgrade_id: String) -> void:
	UpgradeManager.apply_upgrade(upgrade_id, player)
	var cur_lvl_title = LEVELS_DATA[current_level_idx].get("level_title", "")
	UpgradeManager.advance_tier(cur_lvl_title)
	_proceed_to_next_level()


func _proceed_to_next_level() -> void:
	# Advance to next level
	current_level_idx += 1
	load_current_level()
	spawn_level_enemies()

	# Reposition player to spawn point and restore full health & stamina
	if player:
		UpgradeManager.sync_player_stats(player)
		player.global_position = SPAWN_POS
		player.velocity = Vector2.ZERO
		last_player_x = SPAWN_POS.x
		if player.has_method("reset_combat_state"):
			player.reset_combat_state()
		camera.global_position = Vector2(clamp(SPAWN_POS.x, 320.0, current_level_width - 320.0), 180.0)

	# Fade in from black over 0.5s
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, 0.50)
	tween.tween_callback(Callable(self, "_on_fade_in_complete"))"""

assert target7 in main_content, "target7 not found"
main_content = main_content.replace(target7, repl7, 1)

# 8. Permadeath in _on_player_died
target8 = """func _on_player_died() -> void:
	death_count += 1
	is_player_dead = true
	respawn_player_at_checkpoint()
	show_respawn_message()"""

repl8 = """func _on_player_died() -> void:
	death_count += 1
	is_player_dead = true
	var cur_title = LEVELS_DATA[current_level_idx].get("full_title", "Level 1-1")
	var elapsed = (Time.get_ticks_msec() - UpgradeManager.run_start_time_msec) / 1000.0
	if is_instance_valid(game_over_ui):
		game_over_ui.display_defeat(cur_title, UpgradeManager.total_kills_this_run, elapsed, UpgradeManager.active_upgrades)
	else:
		respawn_player_at_checkpoint()
		show_respawn_message()


func _on_restart_run_requested() -> void:
	restart_game()


func _on_return_to_title_requested() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")"""

assert target8 in main_content, "target8 not found"
main_content = main_content.replace(target8, repl8, 1)

# 9. restart_game resets run
target9 = """func restart_game() -> void:
	is_game_won = false
	is_player_dead = false
	is_transitioning = false
	win_overlay.visible = false"""

repl9 = """func restart_game() -> void:
	UpgradeManager.reset_run()
	if is_instance_valid(game_over_ui):
		game_over_ui.visible = false
	if is_instance_valid(upgrade_select_ui):
		upgrade_select_ui.visible = false
	is_game_won = false
	is_player_dead = false
	is_transitioning = false
	win_overlay.visible = false"""

assert target9 in main_content, "target9 not found"
main_content = main_content.replace(target9, repl9, 1)

# 10. Aswang and skeleton kill counters sync to UpgradeManager
main_content = main_content.replace("aswang_kills += 1\n", "aswang_kills += 1\n\tUpgradeManager.total_kills_this_run += 1\n")
main_content = main_content.replace("skeleton_kills += 1\n", "skeleton_kills += 1\n\tUpgradeManager.total_kills_this_run += 1\n")

# 11. Endless loop button in win epilogue
target11 = """	var btn_again := Button.new()
	btn_again.text = "  JOURNEY ANEW (R)  "
	btn_again.custom_minimum_size = Vector2(170, 30)
	btn_again.add_theme_font_override("font", custom_font)
	btn_again.add_theme_font_size_override("font_size", 13)
	btn_again.pressed.connect(func(): restart_game())
	btn_row.add_child(btn_again)"""

repl11 = """	var btn_loop := Button.new()
	btn_loop.text = "  THE INFINITE ECLIPSE (LOOP 2+)  "
	btn_loop.custom_minimum_size = Vector2(210, 30)
	btn_loop.add_theme_font_override("font", custom_font)
	btn_loop.add_theme_font_size_override("font_size", 13)
	btn_loop.pressed.connect(func():
		UpgradeManager.begin_new_loop()
		restart_game()
	)
	btn_row.add_child(btn_loop)

	var btn_again := Button.new()
	btn_again.text = "  FRESH RUN (R)  "
	btn_again.custom_minimum_size = Vector2(150, 30)
	btn_again.add_theme_font_override("font", custom_font)
	btn_again.add_theme_font_size_override("font_size", 13)
	btn_again.pressed.connect(func(): restart_game())
	btn_row.add_child(btn_again)"""

assert target11 in main_content, "target11 not found"
main_content = main_content.replace(target11, repl11, 1)

main_content = main_content.replace("\n", nl)
with open("scripts/main.gd", "w", encoding="utf-8") as f:
    f.write(main_content)
print("scripts/main.gd patched successfully!")
