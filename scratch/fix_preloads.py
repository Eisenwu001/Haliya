# 1. main.gd
with open("scripts/main.gd", "r", encoding="utf-8") as f:
    main_txt = f.read()

if "const UpgradeManager = preload" not in main_txt:
    main_txt = main_txt.replace(
        'const GameOverUIScript = preload("res://scripts/game_over_ui.gd")',
        'const GameOverUIScript = preload("res://scripts/game_over_ui.gd")\nconst UpgradeManager = preload("res://scripts/upgrade_manager.gd")'
    )
    with open("scripts/main.gd", "w", encoding="utf-8") as f:
        f.write(main_txt)
    print("main.gd preload added!")

# 2. game_over_ui.gd
with open("scripts/game_over_ui.gd", "r", encoding="utf-8") as f:
    go_txt = f.read()

if "const UpgradeManager = preload" not in go_txt:
    go_txt = go_txt.replace(
        'const FONT_RES = preload("res://alagard.ttf")',
        'const FONT_RES = preload("res://alagard.ttf")\nconst UpgradeManager = preload("res://scripts/upgrade_manager.gd")'
    )
    with open("scripts/game_over_ui.gd", "w", encoding="utf-8") as f:
        f.write(go_txt)
    print("game_over_ui.gd preload added!")

# 3. upgrade_select_ui.gd
with open("scripts/upgrade_select_ui.gd", "r", encoding="utf-8") as f:
    up_txt = f.read()

if "const UpgradeManager = preload" not in up_txt:
    up_txt = up_txt.replace(
        'const FONT_RES = preload("res://alagard.ttf")',
        'const FONT_RES = preload("res://alagard.ttf")\nconst UpgradeManager = preload("res://scripts/upgrade_manager.gd")'
    )
    with open("scripts/upgrade_select_ui.gd", "w", encoding="utf-8") as f:
        f.write(up_txt)
    print("upgrade_select_ui.gd preload added!")
