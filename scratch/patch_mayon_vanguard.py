with open('scripts/mayon_vanguard_miniboss.gd', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('\r\n', '\n')

# 1. Signals
sig_old = "signal miniboss_died(enemy: MayonVanguardMiniboss)\n"
sig_new = "signal miniboss_died(enemy: MayonVanguardMiniboss)\nsignal boss_hp_changed(current_hp: int, max_hp: int)\nsignal boss_phase_changed(new_phase: int)\n"
assert sig_old in text, "sig_old not found"
text = text.replace(sig_old, sig_new)

# 2. Overhead pips
pips_old = """\t# Health Pips (20 HP)
\thealth_pips = EnemyHealthPipsClass.new()
\thealth_pips.name = "EnemyHealthPips"
\thealth_pips.position = Vector2(0, -84.0)
\tadd_child(health_pips)
\thealth_pips.update_health(health, MAX_HEALTH)"""

pips_new = """\t# Overhead health pips disabled - boss health is displayed in the bottom cinematic Boss HUD
\thealth_pips = null"""

assert pips_old in text, "pips_old not found"
text = text.replace(pips_old, pips_new)

# 3. Emit signals on damage
dmg_old = """\thealth = max(0, health - actual_damage)
\tif is_instance_valid(health_pips):
\t\thealth_pips.update_health(health, MAX_HEALTH, is_stunned_vulnerable)
\t\t
\thurt_flash_timer = 0.22
\tsprite.modulate = Color(2.5, 0.4, 0.4, 1.0)
\t
\t# Check Enrage at <= 50% HP
\tif not is_enraged and health <= int(MAX_HEALTH * 0.5):
\t\tis_enraged = true
\t\tplay_sound(ProceduralAudioScript.get_boss_roar(), 1.0)
\t\t_trigger_screen_shake(0.55)
\t\tspawn_volcanic_sparks(Color(1.0, 0.2, 0.1, 0.95), 14)"""

dmg_new = """\thealth = max(0, health - actual_damage)
\tif is_instance_valid(health_pips):
\t\thealth_pips.update_health(health, MAX_HEALTH, is_stunned_vulnerable)
\tboss_hp_changed.emit(health, MAX_HEALTH)
\t\t
\thurt_flash_timer = 0.22
\tsprite.modulate = Color(2.5, 0.4, 0.4, 1.0)
\t
\t# Check Enrage at <= 50% HP
\tif not is_enraged and health <= int(MAX_HEALTH * 0.5):
\t\tis_enraged = true
\t\tboss_phase_changed.emit(2)
\t\tplay_sound(ProceduralAudioScript.get_boss_roar(), 1.0)
\t\t_trigger_screen_shake(0.55)
\t\tspawn_volcanic_sparks(Color(1.0, 0.2, 0.1, 0.95), 14)"""

assert dmg_old in text, "dmg_old not found"
text = text.replace(dmg_old, dmg_new)

with open('scripts/mayon_vanguard_miniboss.gd', 'w', encoding='utf-8') as f:
    f.write(text)

print("Successfully patched scripts/mayon_vanguard_miniboss.gd")
