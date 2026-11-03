import sys

# ── 3. Skeleton ───────────────────────────────────────────────────────────────
with open("scripts/skeleton.gd", "r", encoding="utf-8") as f:
    skeleton = f.read()

nl = "\r\n" if "\r\n" in skeleton else "\n"
skeleton = skeleton.replace("\r\n", "\n")

if "var max_health: int = MAX_HEALTH" not in skeleton:
    target_s1 = "var health: int = MAX_HEALTH\n"
    repl_s1 = """var health: int = MAX_HEALTH
var max_health: int = MAX_HEALTH
var is_elite: bool = false
var speed_multiplier: float = 1.0

func apply_difficulty_scaling(hp_mult: float, spd_mult: float, elite: bool = false) -> void:
	is_elite = elite
	speed_multiplier = spd_mult
	if is_elite:
		max_health = int(round(MAX_HEALTH * hp_mult * 1.5))
		speed_multiplier *= 1.20
		if is_instance_valid(sprite):
			sprite.modulate = Color(1.35, 0.45, 0.85, 1.0)
	else:
		max_health = int(round(MAX_HEALTH * hp_mult))
	health = max_health
	if is_instance_valid(health_pips):
		health_pips.update_health(health, max_health)
"""
    assert target_s1 in skeleton, "skeleton target_s1 not found"
    skeleton = skeleton.replace(target_s1, repl_s1, 1)

    # Speeds
    skeleton = skeleton.replace("velocity.x = patrol_direction * PATROL_SPEED", "velocity.x = patrol_direction * (PATROL_SPEED * speed_multiplier)")
    skeleton = skeleton.replace("velocity.x = dir_to_player * CHASE_SPEED", "velocity.x = dir_to_player * (CHASE_SPEED * speed_multiplier)")

    # Health pips in take_damage
    skeleton = skeleton.replace("health_pips.update_health(0, MAX_HEALTH, false)", "health_pips.update_health(0, max_health, false)")
    skeleton = skeleton.replace("health_pips.update_health(health, MAX_HEALTH, false)", "health_pips.update_health(health, max_health, false)")
    skeleton = skeleton.replace("health_pips.update_health(health, MAX_HEALTH, true)", "health_pips.update_health(health, max_health, true)")

    # Elite death text
    target_s_death = """func shatter_death(knock_dir: float) -> void:
	if is_dead:
		return
	is_dead = true"""
    repl_s_death = """func shatter_death(knock_dir: float) -> void:
	if is_dead:
		return
	is_dead = true
	if is_elite:
		VFX.spawn_floating_text(get_parent(), global_position + Vector2(0, -60.0), "✦ ELITE SLAIN ✦", Color(1.0, 0.85, 0.35), 14, true)"""
    assert target_s_death in skeleton, "skeleton death target not found"
    skeleton = skeleton.replace(target_s_death, repl_s_death, 1)

    skeleton = skeleton.replace("\n", nl)
    with open("scripts/skeleton.gd", "w", encoding="utf-8") as f:
        f.write(skeleton)
    print("Skeleton patched!")
