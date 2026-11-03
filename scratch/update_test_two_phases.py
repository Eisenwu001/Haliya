with open("scripts/test_forest_miniboss_two_phases.gd", "r", encoding="utf-8") as f:
    text = f.read()

old_test = """\t# 2. Test Phase 1 Damage & 50% Threshold Trigger
\t# Deal 10 damage (28 -> 18 HP)
\tbrute.take_damage(10, 1.0)
\t_check(brute.health == 18, "Health should be 18 after 10 damage")
\t_check(not brute.is_phase_2, "Should still be in Phase 1 at 18 HP")
\t_check(hp_signal_received[0] == 18, "boss_hp_changed signal should emit 18")

\t# Deal 4 more damage (18 -> 14 HP, hitting <= 14 50% threshold!)
\tbrute.take_damage(4, 1.0)
\t_check(brute.has_transitioned_to_phase_2, "Phase transition must trigger at 50% HP (<= 14 HP)")
\t_check(brute.current_state == ForestBruteMiniboss.State.WEAPON_PICKUP_REGEN, "Must enter WEAPON_PICKUP_REGEN state")
\t_check(brute.is_invulnerable, "Must be invulnerable during weapon pickup")
\tprint("PASS: 50% HP trigger successfully initiated weapon pickup & regen state!")

\t# 3. Simulate Weapon Pickup & Health Regen
\t# Advance physics process through the pickup sequence
\tvar total_time: float = 0.0
\twhile total_time < 2.5:
\t\tbrute._physics_process(0.1)
\t\ttotal_time += 0.1

\t_check(brute.is_phase_2, "Must now be in Phase 2 (Armed with weapon)")
\t_check(brute.is_enraged, "Must be enraged in Phase 2")
\t_check(phase_signal_received[0] == 2, "boss_phase_changed signal must have emitted 2")
\t_check(not brute.is_invulnerable, "Must not be invulnerable after completing pickup")
\t_check(brute.health == 22, "Health must have regenerated to 22 HP, got %d" % brute.health)
\tprint("PASS: Weapon pickup completed! Health regenerated to 22 HP and Phase 2 armed state active!")

\t# 4. Test Phase 2 Combat & Final Defeat
\tvar died_signal_emitted: Array[bool] = [false]
\tvar miniboss_died_emitted: Array[bool] = [false]
\tbrute.aswang_died.connect(func(_e): died_signal_emitted[0] = true)
\tbrute.miniboss_died.connect(func(_e): miniboss_died_emitted[0] = true)

\t# Take fatal damage in Phase 2 (22 damage)
\tbrute.take_damage(22, -1.0)"""

new_test = """\t# 2. Test Phase 1 Damage & 10% Threshold Trigger
\t# Deal 20 damage (28 -> 8 HP)
\tbrute.take_damage(20, 1.0)
\t_check(brute.health == 8, "Health should be 8 after 20 damage")
\t_check(not brute.is_phase_2, "Should still be in Phase 1 at 8 HP (~28%)")
\t_check(hp_signal_received[0] == 8, "boss_hp_changed signal should emit 8")

\t# Deal 5 more damage (8 -> 3 HP, hitting <= 3, exactly 10% threshold!)
\tbrute.take_damage(5, 1.0)
\t_check(brute.has_transitioned_to_phase_2, "Phase transition must trigger at 10% HP (<= 3 HP)")
\t_check(brute.current_state == ForestBruteMiniboss.State.WEAPON_PICKUP_REGEN, "Must enter WEAPON_PICKUP_REGEN state")
\t_check(brute.is_invulnerable, "Must be invulnerable during weapon pickup")
\tprint("PASS: 10% HP trigger successfully initiated weapon pickup & regen state!")

\t# 3. Simulate Weapon Pickup & Health Regen
\t# Advance physics process through the pickup sequence
\tvar total_time: float = 0.0
\twhile total_time < 2.5:
\t\tbrute._physics_process(0.1)
\t\ttotal_time += 0.1

\t_check(brute.is_phase_2, "Must now be in Phase 2 (Armed with weapon)")
\t_check(brute.is_enraged, "Must be enraged in Phase 2")
\t_check(phase_signal_received[0] == 2, "boss_phase_changed signal must have emitted 2")
\t_check(not brute.is_invulnerable, "Must not be invulnerable after completing pickup")
\t_check(brute.health == 28, "Health must have regenerated to full (28 HP), got %d" % brute.health)
\tprint("PASS: Weapon pickup completed! Health regenerated to full 28 HP and Phase 2 armed state active!")

\t# 4. Test Phase 2 Combat & Final Defeat
\tvar died_signal_emitted: Array[bool] = [false]
\tvar miniboss_died_emitted: Array[bool] = [false]
\tbrute.aswang_died.connect(func(_e): died_signal_emitted[0] = true)
\tbrute.miniboss_died.connect(func(_e): miniboss_died_emitted[0] = true)

\t# Take fatal damage in Phase 2 (28 damage)
\tbrute.take_damage(28, -1.0)"""

assert old_test in text, "old_test not found"
text = text.replace(old_test, new_test, 1)

with open("scripts/test_forest_miniboss_two_phases.gd", "w", encoding="utf-8") as f:
    f.write(text)

print("Updated test_forest_miniboss_two_phases.gd successfully!")
