import re

with open("scripts/player.gd", "r", encoding="utf-8") as f:
    content = f.read()

# Normalize to \n for python processing
nl = "\r\n" if "\r\n" in content else "\n"
content = content.replace("\r\n", "\n")

# 1. Add fields after exhausted_sound_cooldown
target1 = "var exhausted_sound_cooldown: float = 0.0\n"
repl1 = """var exhausted_sound_cooldown: float = 0.0

# Roguelite Upgrades & Blessings
var bonus_max_hp: int = 0
var bonus_attack_damage: int = 0
var stamina_regen_bonus: float = 0.0
var dodge_cost_reduction: float = 0.0
var move_speed_multiplier: float = 1.0
var has_lunar_aegis: bool = false
var has_vampiric_riposte: bool = false
var has_lunar_shockwave: bool = false
var lunar_shockwave_stacks: int = 0
var has_ghost_dash: bool = false
var has_eclipse_pogo: bool = false

const LunarShockwaveScript = preload("res://scripts/lunar_shockwave.gd")
const GhostDashDecoyScript = preload("res://scripts/ghost_dash_decoy.gd")

func get_max_hp() -> int:
	return MAX_HEALTH + bonus_max_hp

func refresh_max_stats() -> void:
	current_hp = mini(current_hp, get_max_hp())
	hp_changed.emit(current_hp, get_max_hp())

func spawn_lunar_shockwave() -> void:
	var wave = LunarShockwaveScript.new()
	var dir = -1.0 if is_facing_left else 1.0
	wave.direction = dir
	wave.damage = 2 + bonus_attack_damage
	wave.global_position = global_position + Vector2(dir * 28.0, -28.0)
	get_parent().add_child(wave)

func _trigger_eclipse_pogo_burst() -> void:
	VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -20), "ECLIPSE BURST", Color(1.0, 0.85, 0.3), 12, true)
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if is_instance_valid(e) and not e.get("is_dead"):
			var dist = global_position.distance_to(e.global_position + Vector2(0, -30))
			if dist <= 85.0:
				var dir = 1.0 if e.global_position.x >= global_position.x else -1.0
				if e.has_method("take_damage"):
					e.take_damage(2 + bonus_attack_damage, dir)
				if e.has_method("deflect_by_parry"):
					e.deflect_by_parry(dir)
"""

assert target1 in content, "target1 not found"
content = content.replace(target1, repl1, 1)

# 2. Stamina regen bonus
target2 = "current_stamina = min(MAX_STAMINA, current_stamina + STAMINA_REGEN_PER_SEC * delta)"
repl2 = """var regen_rate = STAMINA_REGEN_PER_SEC * (1.0 + stamina_regen_bonus)
				current_stamina = min(MAX_STAMINA, current_stamina + regen_rate * delta)"""
assert target2 in content, "target2 not found"
content = content.replace(target2, repl2, 1)

# 3. Movement speed multiplier
target3 = "var target_speed = RUN_SPEED if is_run_key else WALK_SPEED"
repl3 = "var target_speed = (RUN_SPEED if is_run_key else WALK_SPEED) * move_speed_multiplier"
assert target3 in content, "target3 not found"
content = content.replace(target3, repl3, 1)

target4 = "velocity.x = dodge_direction * DODGE_SPEED * speed_ratio"
repl4 = "velocity.x = dodge_direction * (DODGE_SPEED * move_speed_multiplier) * speed_ratio"
assert target4 in content, "target4 not found"
content = content.replace(target4, repl4, 1)

# 4. Dodge cost reduction, aegis iframe, ghost dash
target5 = """func start_dodge(move_dir: float) -> void:
	if current_state == State.DODGE:
		return
	if is_exhausted or current_stamina < DODGE_STAMINA_COST:
		if is_exhausted and exhausted_sound_cooldown <= 0.0:
			exhausted_sound_cooldown = 0.35
			play_exhausted_effort_tick()
		return
	
	current_stamina = max(0.0, current_stamina - DODGE_STAMINA_COST)
	stamina_regen_timer = STAMINA_REGEN_DELAY
	if current_stamina <= 0.0:
		is_exhausted = true
	stamina_changed.emit(current_stamina, MAX_STAMINA)
	
	dodge_timer = DODGE_DURATION
	invulnerable_timer = DODGE_IFRAME_DURATION"""

repl5 = """func start_dodge(move_dir: float) -> void:
	if current_state == State.DODGE:
		return
	var actual_dodge_cost = DODGE_STAMINA_COST * (1.0 - dodge_cost_reduction)
	if is_exhausted or current_stamina < actual_dodge_cost:
		if is_exhausted and exhausted_sound_cooldown <= 0.0:
			exhausted_sound_cooldown = 0.35
			play_exhausted_effort_tick()
		return
	
	current_stamina = max(0.0, current_stamina - actual_dodge_cost)
	stamina_regen_timer = STAMINA_REGEN_DELAY
	if current_stamina <= 0.0:
		is_exhausted = true
	stamina_changed.emit(current_stamina, MAX_STAMINA)
	
	dodge_timer = DODGE_DURATION
	invulnerable_timer = DODGE_IFRAME_DURATION + (0.06 if has_lunar_aegis else 0.0)"""

assert target5 in content, "target5 not found"
content = content.replace(target5, repl5, 1)

target6 = """	set_state(State.DODGE)
	dodge_trail_timer = 0.0"""
repl6 = """	set_state(State.DODGE)
	dodge_trail_timer = 0.0
	if has_ghost_dash and sprite and sprite.texture:
		var decoy = GhostDashDecoyScript.new()
		decoy.global_position = global_position
		decoy.setup(sprite.texture, sprite.flip_h, sprite.hframes, sprite.vframes, sprite.frame)
		get_parent().add_child(decoy)"""
assert target6 in content, "target6 not found"
content = content.replace(target6, repl6, 1)

# 5. Lunar shockwave on heavy attack / kick
target7 = "var is_heavy = is_air_attack or (current_combo_idx == 3)"
repl7 = """var is_heavy = is_air_attack or (current_combo_idx == 3)
	if has_lunar_shockwave and is_heavy:
		spawn_lunar_shockwave()"""
assert target7 in content, "target7 not found"
content = content.replace(target7, repl7, 1)

target8 = """	set_state(State.RUN_KICK)
	play_kick_launch_sfx()"""
repl8 = """	set_state(State.RUN_KICK)
	if has_lunar_shockwave:
		spawn_lunar_shockwave()
	play_kick_launch_sfx()"""
assert target8 in content, "target8 not found"
content = content.replace(target8, repl8, 1)

# 6. Attack damage upgrade & vampiric riposte & eclipse pogo
target9 = "var damage_amount = RIPOSTE_DAMAGE if is_riposte else (2 if is_heavy else 1)"
repl9 = "var damage_amount = (RIPOSTE_DAMAGE if is_riposte else (2 if is_heavy else 1)) + bonus_attack_damage"
assert target9 in content, "target9 not found"
content = content.replace(target9, repl9, 1)

target10 = """			if is_riposte:
				riposte_performed.emit(enemy.global_position)"""
repl10 = """			if is_riposte:
				riposte_performed.emit(enemy.global_position)
				if has_vampiric_riposte:
					heal(1)"""
assert target10 in content, "target10 not found"
content = content.replace(target10, repl10, 1)

target11 = """			if is_air_attack and dy > 8.0:
				velocity.y = min(velocity.y, -390.0)
				max_fall_velocity = 0.0
				can_air_dash = true
				restore_stamina(20.0)
				VFX.spawn_parry_clash(get_parent(), global_position + Vector2(0.0, 16.0))"""
repl11 = """			if is_air_attack and dy > 8.0:
				var pogo_bounce = -465.0 if has_eclipse_pogo else -390.0
				velocity.y = min(velocity.y, pogo_bounce)
				max_fall_velocity = 0.0
				can_air_dash = true
				restore_stamina(20.0)
				VFX.spawn_parry_clash(get_parent(), global_position + Vector2(0.0, 16.0))
				if has_eclipse_pogo:
					_trigger_eclipse_pogo_burst()"""
assert target11 in content, "target11 not found"
content = content.replace(target11, repl11, 1)

# 7. Heal max HP
target12 = """func heal(amount: int = 1) -> void:
	current_hp = min(MAX_HEALTH, current_hp + amount)
	hp_changed.emit(current_hp, MAX_HEALTH)"""
repl12 = """func heal(amount: int = 1) -> void:
	current_hp = min(get_max_hp(), current_hp + amount)
	hp_changed.emit(current_hp, get_max_hp())"""
assert target12 in content, "target12 not found"
content = content.replace(target12, repl12, 1)

# 8. respawn_at_safe_ledge
target13 = """func respawn_at_safe_ledge(damage: int = 1) -> void:
	current_hp = max(0, current_hp - damage)
	hp_changed.emit(current_hp, MAX_HEALTH)"""
repl13 = """func respawn_at_safe_ledge(damage: int = 1) -> void:
	current_hp = max(0, current_hp - damage)
	hp_changed.emit(current_hp, get_max_hp())"""
assert target13 in content, "target13 not found"
content = content.replace(target13, repl13, 1)

# 9. take_damage
target14 = """func take_damage(amount: int, knockback_dir: float = 0.0) -> void:
	if invulnerable_timer > 0.0 or current_hp <= 0:
		return
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, MAX_HEALTH)"""
repl14 = """func take_damage(amount: int, knockback_dir: float = 0.0) -> void:
	if invulnerable_timer > 0.0 or current_hp <= 0:
		return
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, get_max_hp())"""
assert target14 in content, "target14 not found"
content = content.replace(target14, repl14, 1)

# 10. take_damage_from_enemy (parry window, aegis chip negation, vampiric riposte)
target15 = """	if current_state == State.GUARD and is_facing_enemy:
		# 1. PERFECT BLOCK / PARRY (first 0.20s of guard)
		if guard_time_held <= PARRY_WINDOW:
			# Perfect Parry: 0 damage, 0 stamina cost, +20 bonus stamina surge
			current_stamina = min(MAX_STAMINA, current_stamina + 20.0)
			stamina_changed.emit(current_stamina, MAX_STAMINA)"""
repl15 = """	if current_state == State.GUARD and is_facing_enemy:
		# 1. PERFECT BLOCK / PARRY (first 0.20s of guard, or +0.05s with aegis)
		var parry_window = PARRY_WINDOW + (0.05 if has_lunar_aegis else 0.0)
		if guard_time_held <= parry_window:
			# Perfect Parry: 0 damage, 0 stamina cost, +20 bonus stamina surge
			current_stamina = min(MAX_STAMINA, current_stamina + 20.0)
			stamina_changed.emit(current_stamina, MAX_STAMINA)
			if has_vampiric_riposte:
				heal(1)"""
assert target15 in content, "target15 not found"
content = content.replace(target15, repl15, 1)

target16 = """			# 2. IMPERFECT BLOCK (Holding guard early / long guard)
			# Player feels the hit: 1 chip damage, 35 stamina loss (block meter drain)
			current_hp = max(0, current_hp - 1)
			hp_changed.emit(current_hp, MAX_HEALTH)"""
repl16 = """			# 2. IMPERFECT BLOCK (Holding guard early / long guard)
			# Player feels the hit: 1 chip damage (or 0 with lunar_aegis), 35 stamina loss (block meter drain)
			var chip_dmg = 0 if has_lunar_aegis else 1
			current_hp = max(0, current_hp - chip_dmg)
			hp_changed.emit(current_hp, get_max_hp())"""
assert target16 in content, "target16 not found"
content = content.replace(target16, repl16, 1)

target17 = """	# 3. UNGUARDED HIT: Full damage, heavy knockback, full i-frames
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, MAX_HEALTH)"""
repl17 = """	# 3. UNGUARDED HIT: Full damage, heavy knockback, full i-frames
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, get_max_hp())"""
assert target17 in content, "target17 not found"
content = content.replace(target17, repl17, 1)

# 11. reset_combat_state
target18 = """func reset_combat_state() -> void:
	is_locked_transition = false
	current_hp = MAX_HEALTH
	current_stamina = MAX_STAMINA"""
repl18 = """func reset_combat_state() -> void:
	is_locked_transition = false
	current_hp = get_max_hp()
	current_stamina = MAX_STAMINA"""
assert target18 in content, "target18 not found"
content = content.replace(target18, repl18, 1)

target19 = "hp_changed.emit(current_hp, MAX_HEALTH)\n\tstamina_changed.emit(current_stamina, MAX_STAMINA)"
repl19 = "hp_changed.emit(current_hp, get_max_hp())\n\tstamina_changed.emit(current_stamina, MAX_STAMINA)"
assert target19 in content, "target19 not found"
content = content.replace(target19, repl19, 1)

# Convert back to original line endings and save
content = content.replace("\n", nl)
with open("scripts/player.gd", "w", encoding="utf-8") as f:
    f.write(content)

print("Player script patched successfully!")
