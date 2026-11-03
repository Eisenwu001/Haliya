with open('scripts/test_forest_miniboss_two_phases.gd', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace(
    '_check(brute.health == 28, "Initial health must be 28")',
    '_check(brute.health == 112, "Initial health must be 112")'
)
c = c.replace(
    'PASS: Miniboss initialized in Phase 1 (Barehanded, 28 HP, 10x9 grid)',
    'PASS: Miniboss initialized in Phase 1 (Barehanded, 112 HP, 10x9 grid)'
)
c = c.replace(
    '''\t# Deal 20 damage (28 -> 8 HP)
\tbrute.take_damage(20, 1.0)
\t_check(brute.health == 8, "Health should be 8 after 20 damage")
\t_check(not brute.is_phase_2, "Should still be in Phase 1 at 8 HP (~28%)")
\t_check(hp_signal_received[0] == 8, "boss_hp_changed signal should emit 8")

\t# Deal 5 more damage (8 -> 3 HP, hitting <= 3, exactly 10% threshold!)
\tbrute.take_damage(5, 1.0)
\t_check(brute.has_transitioned_to_phase_2, "Phase transition must trigger at 10% HP (<= 3 HP)")''',
    '''\t# Deal 80 damage (112 -> 32 HP)
\tbrute.take_damage(80, 1.0)
\t_check(brute.health == 32, "Health should be 32 after 80 damage")
\t_check(not brute.is_phase_2, "Should still be in Phase 1 at 32 HP (~28%)")
\t_check(hp_signal_received[0] == 32, "boss_hp_changed signal should emit 32")

\t# Deal 20 more damage (32 -> 12 HP, hitting <= 12, exactly 10% threshold!)
\tbrute.take_damage(20, 1.0)
\t_check(brute.has_transitioned_to_phase_2, "Phase transition must trigger at 10% HP (<= 12 HP)")'''
)
c = c.replace(
    '_check(brute.health == 28, "Health must have regenerated to full (28 HP), got %d" % brute.health)',
    '_check(brute.health == 112, "Health must have regenerated to full (112 HP), got %d" % brute.health)'
)
c = c.replace(
    'PASS: Weapon pickup completed! Health regenerated to full 28 HP and Phase 2 armed state active!',
    'PASS: Weapon pickup completed! Health regenerated to full 112 HP and Phase 2 armed state active!'
)
c = c.replace(
    '''\t# Take fatal damage in Phase 2 (28 damage)
\tbrute.take_damage(28, -1.0)''',
    '''\t# Take fatal damage in Phase 2 (112 damage)
\tbrute.take_damage(112, -1.0)'''
)

with open('scripts/test_forest_miniboss_two_phases.gd', 'w', encoding='utf-8') as f:
    f.write(c)

print("SUCCESS: scripts/test_forest_miniboss_two_phases.gd updated!")
