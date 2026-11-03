with open("scripts/player.gd", "r", encoding="utf-8") as f:
    content = f.read()

# 1. Add MetaProgression preload and get_max_stamina, get_attack_damage_bonus
old_hp_block = """const LunarShockwaveScript = preload("res://scripts/lunar_shockwave.gd")
const GhostDashDecoyScript = preload("res://scripts/ghost_dash_decoy.gd")

func get_max_hp() -> int:
\treturn MAX_HEALTH + bonus_max_hp"""

new_hp_block = """const LunarShockwaveScript = preload("res://scripts/lunar_shockwave.gd")
const GhostDashDecoyScript = preload("res://scripts/ghost_dash_decoy.gd")
const MetaProgression = preload("res://scripts/meta_progression.gd")

func get_max_hp() -> int:
\treturn MAX_HEALTH + bonus_max_hp + MetaProgression.perk_vitality_rank

func get_max_stamina() -> float:
\treturn MAX_STAMINA + (float(MetaProgression.perk_stamina_rank) * 15.0)

func get_attack_damage_bonus() -> int:
\treturn bonus_attack_damage + MetaProgression.perk_damage_rank"""

assert old_hp_block in content, "old_hp_block not found"
content = content.replace(old_hp_block, new_hp_block, 1)

# 2. Update shockwave damage and pogo burst
content = content.replace("wave.damage = 2 + bonus_attack_damage", "wave.damage = 2 + get_attack_damage_bonus()")
content = content.replace("e.take_damage(2 + bonus_attack_damage, dir)", "e.take_damage(2 + get_attack_damage_bonus(), dir)")

# 3. Update attack damage calculation
old_dmg = "var damage_amount = (RIPOSTE_DAMAGE if is_riposte else (2 if is_heavy else 1)) + bonus_attack_damage"
new_dmg = "var damage_amount = (RIPOSTE_DAMAGE if is_riposte else (2 if is_heavy else 1)) + get_attack_damage_bonus()"
assert old_dmg in content, "old_dmg not found"
content = content.replace(old_dmg, new_dmg)

# 4. In reset_combat_state, set stamina and hp to max with perks
old_reset = """\tcurrent_hp = get_max_hp()
\tcurrent_stamina = MAX_STAMINA"""
new_reset = """\tcurrent_hp = get_max_hp()
\tcurrent_stamina = get_max_stamina()"""
assert old_reset in content, "old_reset not found"
content = content.replace(old_reset, new_reset)

# 5. In reset_combat_state, emit stamina_changed with get_max_stamina()
content = content.replace(
    "\thp_changed.emit(current_hp, get_max_hp())\n\tstamina_changed.emit(current_stamina, MAX_STAMINA)",
    "\thp_changed.emit(current_hp, get_max_hp())\n\tstamina_changed.emit(current_stamina, get_max_stamina())"
)

# 6. In restore_stamina:
old_restore = """func restore_stamina(amount: float = 60.0) -> void:
\tcurrent_stamina = min(MAX_STAMINA, current_stamina + amount)
\tstamina_changed.emit(current_stamina, MAX_STAMINA)"""

new_restore = """func restore_stamina(amount: float = 60.0) -> void:
\tcurrent_stamina = min(get_max_stamina(), current_stamina + amount)
\tstamina_changed.emit(current_stamina, get_max_stamina())"""
assert old_restore in content, "old_restore not found"
content = content.replace(old_restore, new_restore)

# 7. In physics_process regen:
content = content.replace(
    "current_stamina = min(MAX_STAMINA, current_stamina + regen_rate * delta)",
    "current_stamina = min(get_max_stamina(), current_stamina + regen_rate * delta)"
)
content = content.replace(
    "current_stamina = min(MAX_STAMINA, current_stamina + 20.0)",
    "current_stamina = min(get_max_stamina(), current_stamina + 20.0)"
)

# 8. In _ready, initialize stats:
old_ready = """func _ready() -> void:
\tz_index = 5
\ttexture_filter = CanvasItem.TEXTURE_FILTER_NEAREST"""

new_ready = """func _ready() -> void:
\tz_index = 5
\ttexture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
\tMetaProgression.load_meta()
\tcurrent_hp = get_max_hp()
\tcurrent_stamina = get_max_stamina()"""
assert old_ready in content, "old_ready not found"
content = content.replace(old_ready, new_ready)

with open("scripts/player.gd", "w", encoding="utf-8") as f:
    f.write(content)

print("scripts/player.gd successfully updated with MetaProgression perks!")
