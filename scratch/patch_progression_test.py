with open('scripts/test_progression_system.gd', 'r', encoding='utf-8') as f:
    text = f.read().replace('\r\n', '\n')

old_part = """\tvar test_upgrades = {"moonstone_vitality": 2, "vampiric_riposte": 1}
\tgo_ui.display_defeat("Level 2-1: Emerald Terraces", 14, 125.0, test_upgrades)
\tassert(go_ui.visible == true, "GameOverUI should be visible")
\tassert("Level 2-1" in go_ui.stats_label.text, "Stats label should display deepest level")
\tassert("14" in go_ui.stats_label.text, "Stats label should display kills")
\tassert("Moonstone Vitality x2" in go_ui.upgrades_label.text, "Upgrades label should display acquired upgrades")
\t
\tvar restart_box = [false]
\tgo_ui.restart_run_requested.connect(func(): restart_box[0] = true)
\tgo_ui.on_restart_pressed()
\tassert(restart_box[0] == true, "GameOverUI should trigger restart_run_requested")"""

new_part = """\tvar test_upgrades = {"moonstone_vitality": 2, "vampiric_riposte": 1}
\tgo_ui.display_defeat("Level 2-1: Emerald Terraces", 14, 125.0, test_upgrades)
\tassert(go_ui.visible == true, "GameOverUI should be visible")
\tassert("Level 2-1" in go_ui.stat_stage_lbl.text, "Stat stage label should display deepest level")
\tassert("14" in go_ui.stat_kills_lbl.text, "Stat kills label should display kills")
\tassert("Moonstone Vitality x2" in go_ui.upgrades_label.text, "Upgrades label should display acquired upgrades")
\t
\tvar restart_box = [false]
\tgo_ui.restart_run_requested.connect(func(): restart_box[0] = true)
\tgo_ui.btn_restart.disabled = false
\tgo_ui.on_restart_pressed()
\tassert(restart_box[0] == true, "GameOverUI should trigger restart_run_requested")"""

assert old_part in text, "old_part not found"
text = text.replace(old_part, new_part)

with open('scripts/test_progression_system.gd', 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated test_progression_system.gd")
