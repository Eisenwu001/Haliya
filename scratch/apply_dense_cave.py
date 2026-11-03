import os
import re

# Complete dense, atmospheric Hollow Knight cavern generator for Level 4-1
dense_level_4_1_code = '''def generate_level_4_1():
    """
    Level 4-1: Bioluminescent Threshold (Hollow Knight Dense Cavern Labyrinth)
    Dimensions: 6,400px wide (200 cols) x 1,152px tall (36 rows)
    Enclosed, atmospheric subterranean karst cavern with tight winding tunnels,
    jagged stalactite ceilings, sheer vertical chimneys, and dense platforming.
    """
    base_cells: Dict[Tuple[int, int], Tuple[int, int, int, int]] = {}

    # === CHAMBER 1: The Enclosed Entry Cavern (x=0..1088, Y=288) ===
    # Entry Floor Terrace: cols 0..34 (x=0..1088), rows 9..14 (y=288..448)
    paint_ground_block(base_cells, 0, 34, 9, 14, "sapphire", 101)
    # Cavern Ceiling Overhang (dense 192px clearance above player): cols 0..40 (x=0..1280), rows 0..3 (y=0..96)
    paint_ground_block(base_cells, 0, 40, 0, 3, "sapphire", 102)
    # Natural Cave Stalactite Arch: col 16..18, rows 4..5 (hanging rock arch)
    paint_ground_block(base_cells, 16, 18, 4, 5, "sapphire", 103)

    # === CHAMBER 2: The Tight Karst Shaft / Vertical Descent (x=1088..1504, 416px wide shaft) ===
    # Left cliff wall of the shaft: cols 32..34 (x=1024..1088), rows 10..26 (y=320..832)
    paint_ground_block(base_cells, 32, 34, 10, 26, "sapphire", 104)
    # Right cliff wall / massive cavern divider: cols 47..52 (x=1504..1664), rows 0..22 (y=0..704)
    paint_ground_block(base_cells, 47, 52, 0, 22, "basalt", 105)
    # Mid-shaft rock outcropping shelf (wall ledge): cols 44..46 (x=1408..1472), rows 14..15 (y=448..480)
    paint_ground_block(base_cells, 44, 46, 14, 15, "sapphire", 106)
    # Lower shaft rock tooth: cols 35..37 (x=1120..1184), rows 20..21 (y=640..672)
    paint_ground_block(base_cells, 35, 37, 20, 21, "sapphire", 107)

    # === CHAMBER 3: The Sunken Sapphire Grotto (x=1504..3200, Y=864) ===
    # Grotto Bedrock Floor 1: cols 35..58 (x=1120..1856), rows 27..35 (y=864..1120)
    paint_ground_block(base_cells, 35, 58, 27, 35, "sapphire", 108)
    # Trench 1 Bedrock Pit (narrow 96px hazard gap): cols 59..61 (x=1888..1952), rows 31..35 (y=992..1120)
    paint_ground_block(base_cells, 59, 61, 31, 35, "sapphire", 109)
    # Grotto Middle Island Terrace: cols 62..75 (x=1984..2400), rows 27..35 (y=864..1120)
    paint_ground_block(base_cells, 62, 75, 27, 35, "sapphire", 110)
    # Trench 2 Bedrock Pit: cols 76..78 (x=2432..2496), rows 31..35 (y=992..1120)
    paint_ground_block(base_cells, 76, 78, 31, 35, "sapphire", 111)
    # Grotto Eastern Bastion: cols 79..100 (x=2528..3200), rows 27..35 (y=864..1120)
    paint_ground_block(base_cells, 79, 100, 27, 35, "sapphire", 112)
    # Low Enclosed Cavern Ceiling (dense, claustrophobic grotto atmosphere): cols 53..86 (x=1696..2752), rows 17..19 (y=544..608)
    paint_ground_block(base_cells, 53, 86, 17, 19, "basalt", 113)
    # Hanging rock stalactite clusters under grotto ceiling:
    paint_ground_block(base_cells, 66, 68, 20, 21, "basalt", 114)
    paint_ground_block(base_cells, 73, 74, 20, 21, "basalt", 115)

    # === CHAMBER 4: The Ascending Karst Pillar Cathedral (x=3200..4864, climbing from Y=864 to Y=256) ===
    # Deep Abyss Bedrock: cols 101..152 (x=3232..4864), rows 32..35 (y=1024..1120)
    paint_ground_block(base_cells, 101, 152, 32, 35, "basalt", 116)
    # Pillar I (The Stele of Libulan): cols 104..111 (x=3328..3552), rows 20..31 (y=640..992)
    paint_ground_block(base_cells, 104, 111, 20, 31, "sapphire", 117)
    # Pillar II (The Sunken Obelisk): cols 117..124 (x=3744..3968), rows 15..31 (y=480..992)
    paint_ground_block(base_cells, 117, 124, 15, 31, "sapphire", 118)
    # Pillar III (The Spire of Shadows): cols 130..137 (x=4160..4384), rows 11..31 (y=352..992)
    paint_ground_block(base_cells, 130, 137, 11, 31, "sapphire", 119)
    # Pillar IV (High Bastion Bluff): cols 143..150 (x=4576..4800), rows 8..31 (y=256..992)
    paint_ground_block(base_cells, 143, 150, 8, 31, "sapphire", 120)
    # Cathedral High Ceiling with hanging stalactites: cols 101..146 (x=3232..4672), rows 0..2 (y=0..64)
    paint_ground_block(base_cells, 101, 146, 0, 2, "sapphire", 121)
    paint_ground_block(base_cells, 113, 115, 3, 4, "sapphire", 122)
    paint_ground_block(base_cells, 126, 128, 3, 4, "sapphire", 123)
    paint_ground_block(base_cells, 139, 141, 3, 4, "sapphire", 124)

    # === CHAMBER 5: The Upper Sanctuary & Exit Portal (x=4864..6400, Y=288) ===
    # Sanctuary Terrace Floor: cols 151..200 (x=4832..6400), rows 9..14 (y=288..448)
    paint_ground_block(base_cells, 151, 200, 9, 14, "sapphire", 125)
    # Sanctuary High Enclosed Ceiling: cols 147..200 (x=4704..6400), rows 0..3 (y=0..96)
    paint_ground_block(base_cells, 147, 200, 0, 3, "sapphire", 126)

    # Elevated Natural Stone Platforms (organic karst shelves & natural stone arches)
    platforms = [
        # Chamber 1: Entry stone shelf
        ("island_md", 540, 215, False),

        # Chamber 2: Shaft Descent Steps (Controlled 576px drop)
        ("island_md", 1160, 370, False),
        ("bridge",    1280, 560, True),
        ("island_lg", 1260, 750, False),

        # Chamber 3: Grotto Trench Crossings and Island High Overlooks
        ("bridge",    1920, 820, True),   # Natural stone arch across Trench 1
        ("sanctuary", 2220, 760, True),   # On Middle Island
        ("bridge",    2460, 820, True),   # Natural stone arch across Trench 2
        ("island_md", 2860, 750, False),  # East Grotto overlook

        # Chamber 4: The Ascending Karst Cathedral (Climbing from Y=864 to Y=256)
        ("island_md", 3240, 750, False),  # Step from Grotto to Pillar I
        ("bridge",    3650, 560, True),   # Natural rock bridge linking Pillar I to Pillar II
        ("bridge",    4060, 420, True),   # Natural rock bridge linking Pillar II to Pillar III
        ("bridge",    4470, 310, True),   # Natural rock bridge linking Pillar III to Pillar IV
        ("island_md", 4810, 260, False),  # Step from Pillar IV to Sanctuary

        # Chamber 5: Sanctuary Sacred Overlook
        ("sanctuary", 5380, 205, True),
        ("bridge",    5760, 215, False),
    ]

    crumble_ledges = [
        # Chamber 2: Brittle limestone shelf in mid-shaft
        (1340, 460),
        (1380, 660),

        # Chamber 3: High Grotto bonus ledge
        (1750, 720),

        # Chamber 4: High challenge secret ledge
        (3960, 380),

        # Chamber 5: Sanctuary treasure shelves
        (5120, 210),
        (5980, 210),
    ]

    spike_hazards = [
        # Chamber 3 Trenches
        (1888, 992, 96),
        (2432, 992, 96),

        # Chamber 4 Cathedral Abyss Floor
        (3552, 1024, 192),
        (3968, 1024, 192),
        (4384, 1024, 192),
    ]

    enemies_list = [
        # Chamber 1: Entry
        ("CaveHound_1", "aswang_hound", 420, 260),
        ("CaveScout_1", "lesser_aswang", 760, 260),

        # Chamber 2: Shaft
        ("ShaftWisp_1", "corrupted_wisp", 1320, 450),

        # Chamber 3: Deep Grotto
        ("GrottoGolem_1", "stone_golem", 1750, 835),
        ("GrottoTiktik_1", "tiktik", 2180, 835),
        ("GrottoSkeleton_1", "armored_skeleton", 2700, 835),
        ("GrottoWisp_2", "mana_wisp", 2400, 740),

        # Chamber 4: Ascending Cathedral
        ("PillarWisp_1", "corrupted_wisp", 3650, 500),
        ("PillarSigbin_1", "sigbin", 3860, 450),
        ("PillarWisp_2", "mana_wisp", 4280, 320),
        ("BalconyAswang_1", "aswang_berzerker", 4680, 230),

        # Chamber 5: Exit Sanctuary
        ("SanctuaryGuard_1", "armored_skeleton", 5220, 260),
        ("SanctuaryGolem_1", "stone_golem", 5680, 255),
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
text = re.sub(pattern, dense_level_4_1_code + '\n\n\n', text, flags=re.DOTALL)

with open('scripts/build_cave_levels.py', 'w', encoding='utf-8', newline='\r\n') as f:
    f.write(text)

print('Updated build_cave_levels.py with dense, enclosed Hollow Knight cavern geometry!')
