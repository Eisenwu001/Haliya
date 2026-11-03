with open("scripts/forest_brute_miniboss.gd", "r", encoding="utf-8") as f:
    text = f.read()

# 1. Disable overhead health_pips creation in setup_nodes()
old_pips = """\t# Health Pips (18 HP)
\thealth_pips = EnemyHealthPipsClass.new()
\thealth_pips.name = "EnemyHealthPips"
\thealth_pips.position = Vector2(0, -112.0)
\tadd_child(health_pips)
\thealth_pips.update_health(health, MAX_HEALTH)"""

new_pips = """\t# Health is displayed in the bottom cinematic Boss HUD, so overhead pips are disabled
\thealth_pips = null"""

assert old_pips in text, "old_pips not found"
text = text.replace(old_pips, new_pips, 1)

# 2. 10% threshold in take_damage
old_thresh = """\t# Phase 1 -> Phase 2 Transition Trigger:
\t# At 50% HP (<= 14) and hasn't transitioned yet, enter weapon pickup & enrage!
\tif not has_transitioned_to_phase_2 and health <= 14:
\t\thealth = 14"""

new_thresh = """\t# Phase 1 -> Phase 2 Transition Trigger:
\t# Once boss reaches 10% HP (<= 3 HP for 28 max HP), proceed to Phase 2 weapon pickup!
\tvar p2_threshold: int = int(ceil(float(MAX_HEALTH) * 0.10))
\tif not has_transitioned_to_phase_2 and health <= p2_threshold:
\t\thealth = p2_threshold"""

assert old_thresh in text, "old_thresh not found"
text = text.replace(old_thresh, new_thresh, 1)

# 3. Regen in WEAPON_PICKUP_REGEN
old_regen = """\t\t\thealth = int(round(lerp(14.0, 22.0, regen_progress)))"""
new_regen = """\t\t\tvar p2_thresh: float = float(int(ceil(float(MAX_HEALTH) * 0.10)))
\t\t\thealth = int(round(lerp(p2_thresh, float(MAX_HEALTH), regen_progress)))"""

assert old_regen in text, "old_regen not found"
text = text.replace(old_regen, new_regen, 1)

with open("scripts/forest_brute_miniboss.gd", "w", encoding="utf-8") as f:
    f.write(text)

print("Updated forest_brute_miniboss.gd successfully!")
