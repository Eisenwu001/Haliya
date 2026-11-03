import re

def update_forest_brute():
    path = "scripts/forest_brute_miniboss.gd"
    with open(path, "r", encoding="utf-8") as f:
        c = f.read()
    
    # Update MAX_HEALTH from 28 to 112
    c = c.replace("const MAX_HEALTH: int = 28", "const MAX_HEALTH: int = 112")
    with open(path, "w", encoding="utf-8") as f:
        f.write(c)
    print("Updated forest_brute_miniboss.gd: MAX_HEALTH = 112")

def update_other_bosses():
    # Mayon Vanguard
    path_mv = "scripts/mayon_vanguard_miniboss.gd"
    with open(path_mv, "r", encoding="utf-8") as f:
        c = f.read()
    c = c.replace("const MAX_HEALTH: int = 20", "const MAX_HEALTH: int = 80")
    with open(path_mv, "w", encoding="utf-8") as f:
        f.write(c)
    print("Updated mayon_vanguard_miniboss.gd: MAX_HEALTH = 80")

    # Aswang Boss (Manananggal / Matriarch)
    path_ab = "scripts/aswang_boss.gd"
    with open(path_ab, "r", encoding="utf-8") as f:
        c = f.read()
    c = c.replace("const MAX_HEALTH: int = 20", "const MAX_HEALTH: int = 80")
    with open(path_ab, "w", encoding="utf-8") as f:
        f.write(c)
    print("Updated aswang_boss.gd: MAX_HEALTH = 80")

    # Bakunawa Boss
    path_bb = "scripts/bakunawa_boss.gd"
    with open(path_bb, "r", encoding="utf-8") as f:
        c = f.read()
    c = c.replace("const MAX_HEALTH: int = 28", "const MAX_HEALTH: int = 112")
    with open(path_bb, "w", encoding="utf-8") as f:
        f.write(c)
    print("Updated bakunawa_boss.gd: MAX_HEALTH = 112")

def update_normal_monsters():
    # Aswang: 3 -> 6
    path_as = "scripts/aswang.gd"
    with open(path_as, "r", encoding="utf-8") as f:
        c = f.read()
    c = c.replace("const MAX_HEALTH: int = 3", "const MAX_HEALTH: int = 6")
    with open(path_as, "w", encoding="utf-8") as f:
        f.write(c)
    print("Updated aswang.gd: MAX_HEALTH = 6")

    # Skeleton: 4 -> 8
    path_sk = "scripts/skeleton.gd"
    with open(path_sk, "r", encoding="utf-8") as f:
        c = f.read()
    c = c.replace("const MAX_HEALTH: int = 4", "const MAX_HEALTH: int = 8")
    with open(path_sk, "w", encoding="utf-8") as f:
        f.write(c)
    print("Updated skeleton.gd: MAX_HEALTH = 8")

    # Corrupted Farmer: 3 -> 6
    path_cf = "scripts/corrupted_farmer.gd"
    with open(path_cf, "r", encoding="utf-8") as f:
        c = f.read()
    c = c.replace("const MAX_HEALTH: int = 3", "const MAX_HEALTH: int = 6")
    with open(path_cf, "w", encoding="utf-8") as f:
        f.write(c)
    print("Updated corrupted_farmer.gd: MAX_HEALTH = 6")

    # Santelmo: 2 -> 4
    path_st = "scripts/santelmo.gd"
    with open(path_st, "r", encoding="utf-8") as f:
        c = f.read()
    c = c.replace("const BASE_MAX_HEALTH: int = 2", "const BASE_MAX_HEALTH: int = 4")
    with open(path_st, "w", encoding="utf-8") as f:
        f.write(c)
    print("Updated santelmo.gd: BASE_MAX_HEALTH = 4")

    # Possessed Scarecrow: 2 -> 4
    path_sc = "scripts/possessed_scarecrow.gd"
    with open(path_sc, "r", encoding="utf-8") as f:
        c = f.read()
    c = c.replace("const MAX_HEALTH: int = 2", "const MAX_HEALTH: int = 4")
    with open(path_sc, "w", encoding="utf-8") as f:
        f.write(c)
    print("Updated possessed_scarecrow.gd: MAX_HEALTH = 4")

def update_spawns():
    path_lb = "scripts/level_builder.gd"
    with open(path_lb, "r", encoding="utf-8") as f:
        c = f.read()

    # Double sentinels in Level 1-3 from 4 to 8
    c = c.replace("if level_idx == 2:\n\t\tvar sentinels = 4", "if level_idx == 2:\n\t\tvar sentinels = 8")

    # Double sentinels in Level 2-3 from 4 to 8
    c = c.replace("if level_idx == 5:\n\t\tvar sentinels = 4", "if level_idx == 5:\n\t\tvar sentinels = 8")

    # Double general level aswang count: 3 + sub_lvl * 2 -> 6 + sub_lvl * 4
    c = c.replace("var aswang_count = 3 + sub_lvl * 2 # 5, 7, 9", "var aswang_count = 6 + sub_lvl * 4 # 10, 14, 18")
    c = c.replace("aswang_count += 2 # 7, 9, 11", "aswang_count += 4 # 14, 18, 22")
    c = c.replace("if level_idx == 10:\n\t\t# Level 3-5: 4 sentinels along ascent, clearing x >= 3600 for Boss Arena\n\t\taswang_count = 4",
                  "if level_idx == 10:\n\t\t# Level 3-5: 8 sentinels along ascent, clearing x >= 3600 for Boss Arena\n\t\taswang_count = 8")

    with open(path_lb, "w", encoding="utf-8") as f:
        f.write(c)
    print("Updated level_builder.gd: Aswang spawns doubled!")

if __name__ == "__main__":
    update_forest_brute()
    update_other_bosses()
    update_normal_monsters()
    update_spawns()
    print("ALL TUNING SUCCESSFULLY APPLIED!")
