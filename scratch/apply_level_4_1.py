import os
import re

level_4_1_code = '''def generate_level_4_1():
    """
    Level 4-1: Bioluminescent Threshold (Hollow Knight Multi-Chamber Vertical Labyrinth)
    Dimensions: 6,400px wide (200 cols) x 1,152px tall (36 rows)
    5 Connected Chambers:
      1. Cavern Entry & Precipice (Y=288, cols 0..32, x=0..1024)
      2. The Great Karst Shaft / Vertical Descent (dropping 576px from Y=288 to Y=864, cols 30..51, x=1024..1632)
      3. The Sunken Sapphire Grotto (Y=864, cols 52..100, x=1664..3200 with low ceiling at Y=512)
      4. The Ascending Karst Pillar Cathedral (climbing BACK UP from Y=864 to Y=256, cols 101..152, x=3232..4864)
      5. The Upper Sanctuary & Exit Portal (Y=288, cols 153..200, x=4896..6400)
    """
    base_cells: Dict[Tuple[int, int], Tuple[int, int, int, int]] = {}

    # === CHAMBER 1: The Threshold & Entry Cavern ===
    # Entry Terrace: cols 0..32 (x=0..1024), rows 9..14 (y=288..448)
    paint_ground_block(base_cells, 0, 32, 9, 14, "sapphire", 101)
    # Cavern Ceiling Overhang: cols 0..38 (x=0..1216), rows 0..3 (y=0..96)
    paint_ground_block(base_cells, 0, 38, 0, 3, "sapphire", 102)

    # === CHAMBER 2: The Great Karst Shaft / Vertical Descent ===
    # Left cliff wall of the shaft: cols 30..32 (x=960..1024), rows 15..26 (y=480..832)
    paint_ground_block(base_cells, 30, 32, 15, 26, "sapphire", 103)
    # Right cliff wall / divider: cols 48..51 (x=1536..1632), rows 0..20 (y=0..640)
    paint_ground_block(base_cells, 48, 51, 0, 20, "basalt", 104)

    # === CHAMBER 3: The Sunken Sapphire Grotto ===
    # Grotto Bedrock Floor 1: cols 33..64 (x=1056..2048), rows 27..35 (y=864..1120)
    paint_ground_block(base_cells, 33, 64, 27, 35, "sapphire", 105)
    # Trench 1 Bedrock Pit: cols 65..70 (x=2080..2240), rows 31..35 (y=992..1120)
    paint_ground_block(base_cells, 65, 70, 31, 35, "sapphire", 106)
    # Grotto Sunken Island: cols 71..83 (x=2272..2656), rows 27..35 (y=864..1120)
    paint_ground_block(base_cells, 71, 83, 27, 35, "sapphire", 107)
    # Trench 2 Bedrock Pit: cols 84..88 (x=2688..2816), rows 31..35 (y=992..1120)
    paint_ground_block(base_cells, 84, 88, 31, 35, "sapphire", 108)
    # Grotto Bastion: cols 89..100 (x=2848..3200), rows 27..35 (y=864..1120)
    paint_ground_block(base_cells, 89, 100, 27, 35, "sapphire", 109)
    # Grotto Low Ceiling Overhang: cols 52..86 (x=1664..2752), rows 16..18 (y=512..576)
    paint_ground_block(base_cells, 52, 86, 16, 18, "basalt", 110)

    # === CHAMBER 4: The Ascending Karst Pillar Cathedral ===
    # Abyss Deep Floor below pillars: cols 101..152 (x=3232..4864), rows 32..35 (y=1024..1120)
    paint_ground_block(base_cells, 101, 152, 32, 35, "basalt", 111)
    # Pillar I (Low Stele): cols 105..111 (x=3360..3552), rows 20..31 (y=640..992)
    paint_ground_block(base_cells, 105, 111, 20, 31, "sapphire", 112)
    # Pillar II (Sunken Obelisk): cols 118..125 (x=3776..4000), rows 15..31 (y=480..992)
    paint_ground_block(base_cells, 118, 125, 15, 31, "sapphire", 113)
    # Pillar III (Spire of Libulan): cols 132..139 (x=4224..4448), rows 11..31 (y=352..992)
    paint_ground_block(base_cells, 132, 139, 11, 31, "sapphire", 114)
    # Pillar IV (High Balcony): cols 146..152 (x=4672..4864), rows 8..31 (y=256..992)
    paint_ground_block(base_cells, 146, 152, 8, 31, "sapphire", 115)

    # === CHAMBER 5: The Upper Sanctuary & Exit Portal ===
    # Sanctuary Terrace Floor: cols 153..200 (x=4896..6400), rows 9..14 (y=288..448)
    paint_ground_block(base_cells, 153, 200, 9, 14, "sapphire", 116)
    # Sanctuary High Ceiling: cols 148..200 (x=4736..6400), rows 0..3 (y=0..96)
    paint_ground_block(base_cells, 148, 200, 0, 3, "sapphire", 117)

    # Elevated Platforms providing seamless transitions between landmass tiers
    platforms = [
        # Chamber 1: Entry warm-up ledge
        ("island_md", 560, 215, False),

        # Chamber 2: Vertical Shaft Descent Steps (Controlling 576px drop down to Y=864)
        ("island_md", 1160, 380, False),
        ("bridge",    1200, 580, True),
        ("island_lg", 1220, 780, False),

        # Chamber 3: Grotto Trench Crossings and Island High Overlooks
        ("bridge",    2160, 810, True),   # Across Trench 1
        ("sanctuary", 2460, 760, True),   # On Sunken Island
        ("bridge",    2750, 810, True),   # Across Trench 2

        # Chamber 4: The Ascending Karst Cathedral (Climbing from Y=864 to Y=256)
        ("island_md", 3280, 760, False),  # Step from Grotto Bastion to Pillar I
        ("bridge",    3660, 560, True),   # Linking Pillar I to Pillar II
        ("bridge",    4550, 300, True),   # Linking Pillar III to Pillar IV
        ("island_md", 4900, 265, False),  # Step from Pillar IV to Sanctuary

        # Chamber 5: Final Sanctuary Elevated Overlook
        ("sanctuary", 5420, 205, True),
        ("bridge",    5750, 215, False),
    ]

    crumble_ledges = [
        # Chamber 2: Mid-shaft crumbling ledge steps
        (1380, 480),
        (1380, 680),

        # Chamber 3: High Grotto bonus ledge
        (1850, 720),

        # Chamber 4: Crumbling bridge between Pillar II and Pillar III
        (4110, 415),

        # Chamber 5: Sanctuary treasure shelves
        (5150, 210),
        (5950, 210),
    ]

    spike_hazards = [
        # Chamber 3 Trenches
        (2080, 992, 192),
        (2688, 992, 160),

        # Chamber 4 Cathedral Abyss Floor
        (3552, 1024, 224),
        (4000, 1024, 224),
        (4448, 1024, 224),
    ]

    enemies_list = [
        # Chamber 1: Entry
        ("CaveHound_1", "aswang_hound", 420, 260),
        ("CaveScout_1", "lesser_aswang", 760, 260),

        # Chamber 2: Shaft
        ("ShaftWisp_1", "corrupted_wisp", 1350, 460),

        # Chamber 3: Deep Grotto
        ("GrottoGolem_1", "stone_golem", 1880, 835),
        ("GrottoTiktik_1", "tiktik", 2460, 835),
        ("GrottoSkeleton_1", "armored_skeleton", 3000, 835),
        ("GrottoWisp_2", "mana_wisp", 2750, 740),

        # Chamber 4: Ascending Cathedral
        ("PillarWisp_1", "corrupted_wisp", 3680, 500),
        ("PillarSigbin_1", "sigbin", 3880, 450),
        ("PillarWisp_2", "mana_wisp", 4350, 300),
        ("BalconyAswang_1", "aswang_berzerker", 4760, 230),

        # Chamber 5: Exit Sanctuary
        ("SanctuaryGuard_1", "armored_skeleton", 5250, 260),
        ("SanctuaryGolem_1", "stone_golem", 5700, 255),
        ("ExitAswang_1", "Tiktok_Aswang", 6120, 260),
    ]

    build_cave_scene_tscn(
        "level_4_1.tscn", "Level4_1",
        base_cells, platforms, crumble_ledges,
        spike_hazards, enemies_list
    )
    build_cave_scene_tscn(
        "level_4.tscn", "Level4",
        base_cells, platforms, crumble_ledges,
        spike_hazards, enemies_list
    )'''

with open('scripts/build_cave_levels.py', 'r', encoding='utf-8') as f:
    text = f.read()

pattern = r'def generate_level_4_1\(\):.*?(?=def generate_level_4_2)'
text = re.sub(pattern, level_4_1_code + '\n\n\n', text, flags=re.DOTALL)

with open('scripts/build_cave_levels.py', 'w', encoding='utf-8', newline='\r\n') as f:
    f.write(text)

print('Updated build_cave_levels.py with Hollow Knight vertical labyrinth architecture!')
