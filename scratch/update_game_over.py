with open('scripts/game_over_ui.gd', 'r', encoding='utf-8') as f:
    c = f.read()

target1 = "var acquired_upgrades: Dictionary = upgrades"
repl1 = "var acquired_upgrades = upgrades"
assert target1 in c, "target1 not found"
c = c.replace(target1, repl1)

target2 = """\tif acquired_upgrades.is_empty():
\t\tupgrades_label.text = "%s  •  Blessings: None" % tier_str
\telse:
\t\tvar list_str = ""
\t\tfor u_id in acquired_upgrades.keys():
\t\t\tvar info = UpgradeManager.CATALOG.get(u_id, {})
\t\t\tvar u_name = info.get("name", u_id)
\t\t\tvar stk = acquired_upgrades[u_id]
\t\t\tlist_str += "%s x%d, " % [u_name, stk]
\t\tif list_str.ends_with(", "):
\t\t\tlist_str = list_str.left(list_str.length() - 2)
\t\tupgrades_label.text = "%s  •  Blessings: %s" % [tier_str, list_str]"""

repl2 = """\tif acquired_upgrades == null or acquired_upgrades.is_empty():
\t\tupgrades_label.text = "%s  •  Blessings: None" % tier_str
\telif acquired_upgrades is Dictionary:
\t\tvar list_str = ""
\t\tfor u_id in acquired_upgrades.keys():
\t\t\tvar info = UpgradeManager.CATALOG.get(u_id, {})
\t\t\tvar u_name = info.get("name", u_id)
\t\t\tvar stk = acquired_upgrades[u_id]
\t\t\tlist_str += "%s x%d, " % [u_name, stk]
\t\tif list_str.ends_with(", "):
\t\t\tlist_str = list_str.left(list_str.length() - 2)
\t\tupgrades_label.text = "%s  •  Blessings: %s" % [tier_str, list_str]
\telif acquired_upgrades is Array:
\t\tvar list_str = ", ".join(acquired_upgrades)
\t\tupgrades_label.text = "%s  •  Blessings: %s" % [tier_str, list_str]"""

assert target2 in c, "target2 not found"
c = c.replace(target2, repl2)

with open('scripts/game_over_ui.gd', 'w', encoding='utf-8') as f:
    f.write(c)

print("SUCCESS: game_over_ui.gd updated!")
