#!/usr/bin/env python3
"""
Build Cave Levels Generator for Haliya: Mask of Sorrows
Standard 2D platformer dimensions (5120px x 360px) matching the rest of the game:
- Viewport 640x360, camera y=180.0
- Base floor at y=288.0 (row 9..11), 100% solid seamless interior (zero holes)
- Elevated platforms at y=165..245 (jump-reachable, rounded seamless edges)
- Stalagmite spike beds (Tusok ng Bato) at y=320.0
- Checkpoint at x=3620.0, Exit transition at x=5050.0
- Solid arena floors (x=3760..5080) for Miniboss (4-3) and Bakunawa (5)
- All enemies placed on solid footing at y=255.0..260.0
"""

import base64
import os
import shutil
import struct
from typing import Dict, List, Tuple

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CAVE_DIR = os.path.join(BASE_DIR, "scenes", "cave")
os.makedirs(CAVE_DIR, exist_ok=True)


def encode_tile_map_data(cells: Dict[Tuple[int, int], Tuple[int, int, int, int]]) -> str:
    """
    Packs a dict of (col, row) -> (source_id, atlas_x, atlas_y, alt) into Godot 4's
    TileMapLayer binary format (2-byte header [0, 0] + 12 bytes per cell <hhhhhh)
    and returns a base64 string for PackedByteArray("...").
    """
    buf = bytearray([0, 0])
    for (col, row) in sorted(cells.keys(), key=lambda k: (k[1], k[0])):
        src, ax, ay, alt = cells[(col, row)]
        buf.extend(struct.pack("<hhhhhh", col, row, src, ax, ay, alt))
    return base64.b64encode(bytes(buf)).decode("ascii")


def build_cave_tileset_tres():
    """
    Generates scenes/cave/cave_tileset.tres with:
    - source 0: cave_rock_tiles.png (288x384, 9x12 32x32 tiles with collision)
    - one-way collision on thin platform tiles at row 5 and row 11 (cols 6..8)
    """
    lines = [
        '[gd_resource type="TileSet" format=3]',
        '',
        '[ext_resource type="Texture2D" path="res://assets/cave_platformer/cave_rock_tiles.png" id="1_caverock"]',
        '',
        '[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_caverock"]',
        'texture = ExtResource("1_caverock")',
        'texture_region_size = Vector2i(32, 32)',
    ]
    for cy in range(12):
        for cx in range(9):
            lines.append(f'{cx}:{cy}/0 = 0')
            if (cy == 5 or cy == 11) and (6 <= cx <= 8):
                # Thin one-way platform top slab
                lines.append(f'{cx}:{cy}/0/physics_layer_0/polygon_0/points = PackedVector2Array(-16, -16, 16, -16, 16, 0, -16, 0)')
                lines.append(f'{cx}:{cy}/0/physics_layer_0/polygon_0/one_way = true')
                lines.append(f'{cx}:{cy}/0/physics_layer_0/polygon_0/one_way_margin = 1.0')
            else:
                # Solid 32x32 rock block
                lines.append(f'{cx}:{cy}/0/physics_layer_0/polygon_0/points = PackedVector2Array(-16, -16, 16, -16, 16, 16, -16, 16)')

    lines.extend([
        '',
        '[resource]',
        'tile_size = Vector2i(32, 32)',
        'physics_layer_0/collision_layer = 1',
        'physics_layer_0/collision_mask = 1',
        'sources/0 = SubResource("TileSetAtlasSource_caverock")',
        '',
    ])

    tres_path = os.path.join(CAVE_DIR, "cave_tileset.tres")
    with open(tres_path, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines))
    print(f"Wrote {tres_path}")


def paint_ground_block(
    base_cells: Dict[Tuple[int, int], Tuple[int, int, int, int]],
    col_start: int,
    col_end: int,
    row_top: int = 9,
    row_bottom: int = 11,
    variant: str = "sapphire",
    seed_val: int = 1,
):
    """
    Paints seamless autotiled subterranean limestone / volcanic basalt rock block into BaseGround
    from col_start..col_end (inclusive), row_top..row_bottom (inclusive).
    Interior is 100% solid rock fill (ax=1, ay=y_off+1) with zero hole cutouts.
    """
    y_off = 0 if variant == "sapphire" else 6

    for c in range(col_start, col_end + 1):
        is_left = (c == col_start)
        is_right = (c == col_end)
        for r in range(row_top, row_bottom + 1):
            is_top = (r == row_top)
            is_bot = (r == row_bottom and row_bottom < 11)

            if is_top and is_left:
                ax, ay = 0, y_off + 0
            elif is_top and is_right:
                ax, ay = 2, y_off + 0
            elif is_top:
                ax, ay = 1, y_off + 0
            elif is_bot and is_left:
                ax, ay = 0, y_off + 2
            elif is_bot and is_right:
                ax, ay = 2, y_off + 2
            elif is_bot:
                ax, ay = 1, y_off + 2
            elif is_left:
                ax, ay = 0, y_off + 1
            elif is_right:
                ax, ay = 2, y_off + 1
            else:
                # 100% Solid subterranean rock interior
                ax, ay = 1, y_off + 1

            base_cells[(c, r)] = (0, ax, ay, 0)


def paint_pit_bedrock(
    base_cells: Dict[Tuple[int, int], Tuple[int, int, int, int]],
    col_start: int,
    col_end: int,
    variant: str = "sapphire",
):
    """Paints solid bedrock floor at row 11 under a hazard pit so spikes rest naturally on stone."""
    y_off = 0 if variant == "sapphire" else 6
    for c in range(col_start, col_end + 1):
        base_cells[(c, 11)] = (0, 1, y_off + 1, 0)


PLATFORM_SPECS = {
    "island_lg": {"rect": "Rect2(0, 0, 160, 56)", "w": 160.0, "h": 18.0, "spr_y": 28.0},
    "island_md": {"rect": "Rect2(0, 64, 112, 48)", "w": 112.0, "h": 16.0, "spr_y": 24.0},
    "bridge":    {"rect": "Rect2(224, 64, 160, 44)", "w": 160.0, "h": 14.0, "spr_y": 22.0},
    "sanctuary": {"rect": "Rect2(160, 0, 192, 56)", "w": 192.0, "h": 18.0, "spr_y": 28.0},
}


def build_cave_scene_tscn(
    filename: str,
    root_name: str,
    base_cells: Dict[Tuple[int, int], Tuple[int, int, int, int]],
    platforms: List[Tuple[str, float, float]],
    crumble_ledges: List[Tuple[float, float]],
    spike_hazards: List[Tuple[float, float, float]],
    enemies_list: List[Tuple[str, str, float, float]],
):
    """Writes a clean, uncluttered, pure platforming Godot 4 .tscn scene file for a Cave level."""
    sub_resources = []
    node_blocks = []

    # Collect unique RectangleShape2D sizes for platforms
    shape_ids: Dict[Tuple[int, int], str] = {}
    for ptype, _, _ in platforms:
        spec = PLATFORM_SPECS[ptype]
        key = (int(spec["w"]), int(spec["h"]))
        if key not in shape_ids:
            sid = f"RectangleShape2D_{key[0]}x{key[1]}"
            shape_ids[key] = sid
            sub_resources.extend([
                f'[sub_resource type="RectangleShape2D" id="{sid}"]',
                f'size = Vector2({spec["w"]:.1f}, {spec["h"]:.1f})',
                '',
            ])

    base_b64 = encode_tile_map_data(base_cells)

    ext_resources = [
        '[ext_resource type="TileSet" path="res://scenes/cave/cave_tileset.tres" id="1_tileset"]',
        '[ext_resource type="Texture2D" path="res://assets/cave_platformer/cave_platforms.png" id="2_plat"]',
        '[ext_resource type="Script" path="res://scripts/cave_crumble_ledge.gd" id="4_crumble"]',
        '[ext_resource type="Script" path="res://scripts/cave_spike_hazard.gd" id="6_spike"]',
        '[ext_resource type="Script" uid="uid://b6v2malf4os04" path="res://scripts/aswang.gd" id="9_aswang"]',
        '[ext_resource type="Script" path="res://scripts/skeleton.gd" id="10_skeleton"]',
    ]

    # Root + BaseGround TileMapLayer + ElevatedPlatforms
    node_blocks.extend([
        f'[node name="{root_name}" type="Node2D"]',
        '',
        '[node name="BaseGround" type="TileMapLayer" parent="."]',
        'tile_map_data = PackedByteArray("' + base_b64 + '")',
        'tile_set = ExtResource("1_tileset")',
        '',
        '[node name="ElevatedPlatforms" type="Node2D" parent="."]',
        '',
    ])

    # ElevatedPlatforms: Pure organic limestone shelves & bamboo bridges (top edge flush at y=py!)
    for idx, (ptype, px, py) in enumerate(platforms):
        spec = PLATFORM_SPECS[ptype]
        sid = shape_ids[(int(spec["w"]), int(spec["h"]))]
        pname = f"CavePlatform_{idx + 1}"

        node_blocks.extend([
            f'[node name="{pname}" type="StaticBody2D" parent="ElevatedPlatforms"]',
            f'position = Vector2({px:.1f}, {py:.1f})',
            'collision_layer = 1',
            'collision_mask = 1',
            '',
            f'[node name="CollisionShape2D" type="CollisionShape2D" parent="ElevatedPlatforms/{pname}"]',
            f'position = Vector2(0, {spec["h"] * 0.5:.1f})',
            f'shape = SubResource("{sid}")',
            'one_way_collision = true',
            '',
            f'[node name="PlatformVisual" type="Sprite2D" parent="ElevatedPlatforms/{pname}"]',
            f'position = Vector2(0, {spec["spr_y"]:.1f})',
            'texture = ExtResource("2_plat")',
            'region_enabled = true',
            f'region_rect = {spec["rect"]}',
            '',
        ])

    # Crumble Ledges: 100% visible brittle limestone shelf with visible fissures (width 112px)
    for idx, (cx, cy) in enumerate(crumble_ledges):
        cname = f"CrumbleLedge_{idx + 1}"
        node_blocks.extend([
            f'[node name="{cname}" type="StaticBody2D" parent="ElevatedPlatforms"]',
            f'position = Vector2({cx - 56.0:.1f}, {cy:.1f})',
            'script = ExtResource("4_crumble")',
            '',
        ])

    # SpikeHazards: Natural limestone stalagmite hazard bed (Tusok ng Bato)
    node_blocks.extend([
        '[node name="SpikeHazards" type="Node2D" parent="."]',
        '',
    ])
    for idx, (sx, sy, sw) in enumerate(spike_hazards):
        node_blocks.extend([
            f'[node name="SpikeBed_{idx + 1}" type="Area2D" parent="SpikeHazards"]',
            f'position = Vector2({sx:.1f}, {sy:.1f})',
            'script = ExtResource("6_spike")',
            f'hazard_width = {sw:.1f}',
            '',
        ])

    # Enemies: CharacterBody2D placed with exact ground footing
    node_blocks.extend([
        '[node name="Enemies" type="Node2D" parent="."]',
        '',
    ])
    for ename, etype, ex, ey in enemies_list:
        is_skel = ("skeleton" in etype.lower() or "golem" in etype.lower() or "balbal" in etype.lower())
        script_ext = 'ExtResource("10_skeleton")' if is_skel else 'ExtResource("9_aswang")'
        node_blocks.extend([
            f'[node name="{ename}" type="CharacterBody2D" parent="Enemies"]',
            f'position = Vector2({ex:.1f}, {ey:.1f})',
            f'script = {script_ext}',
            '',
        ])

    header = ['[gd_scene format=3]', '']
    full_text = "\n".join(header + ext_resources + [''] + sub_resources + node_blocks)
    out_path = os.path.join(CAVE_DIR, filename)
    with open(out_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(full_text)
    print(f"Wrote {out_path} ({len(base_cells)} ground tiles, {len(platforms)} platforms, {len(crumble_ledges)} crumble, {len(enemies_list)} enemies)")


def generate_level_4_1():
    """
    Level 4-1: Bioluminescent Threshold (Subterranean Karst Cavern)
    Standard: 5120px wide (160 cols) x 360px tall (11 rows)
    Floor at row 9..11 (y=288.0). Checkpoint at x=3620. Exit at x=5050.
    """
    base_cells: Dict[Tuple[int, int], Tuple[int, int, int, int]] = {}

    # === BASE GROUND TERRACES (row 9..11, y=288) ===
    # 1. Entry Threshold: cols 0..38 (x=0..1216)
    paint_ground_block(base_cells, 0, 38, 9, 11, "sapphire", 101)
    # Pit 1 Bedrock: cols 39..43 (x=1248..1376)
    paint_pit_bedrock(base_cells, 39, 43, "sapphire")

    # 2. Crystal Grotto Terrace: cols 44..66 (x=1408..2112)
    paint_ground_block(base_cells, 44, 66, 9, 11, "sapphire", 102)
    # Pit 2 Bedrock: cols 67..73 (x=2144..2336)
    paint_pit_bedrock(base_cells, 67, 73, "sapphire")

    # 3. Stalactite Causeway: cols 74..90 (x=2368..2880)
    paint_ground_block(base_cells, 74, 90, 9, 11, "sapphire", 103)
    # Pit 3 Bedrock: cols 91..97 (x=2912..3104)
    paint_pit_bedrock(base_cells, 91, 97, "sapphire")

    # 4. Deep Cavern Bastion & Checkpoint (x=3620) & Exit Gate: cols 98..160 (x=3136..5120)
    paint_ground_block(base_cells, 98, 160, 9, 11, "sapphire", 104)

    # === ELEVATED PLATFORMS (Organic limestone shelves & bridges) ===
    platforms = [
        # Gap 1 Crossing (x=1216..1408)
        ("bridge",    1312, 235),
        ("island_md", 1100, 240),
        # Grotto High Route (x=1408..2112)
        ("sanctuary", 1620, 205),
        ("island_lg", 1880, 180),
        # Gap 2 Crossing (x=2112..2368)
        ("bridge",    2240, 235),
        ("sanctuary", 2180, 140), # High secret altar
        # Causeway & Gap 3 Crossing (x=2880..3136)
        ("island_md", 2620, 215),
        ("bridge",    3008, 235),
        # Bastion & Checkpoint Approach (x=3136..5120)
        ("sanctuary", 3420, 205),
        ("island_lg", 3900, 215),
        ("bridge",    4260, 220),
        ("island_md", 4580, 205),
        ("sanctuary", 4860, 215),
    ]

    crumble_ledges = [
        (1216, 210),
        (1750, 195),
        (2300, 210),
        (2750, 195),
        (3080, 205),
    ]

    spike_hazards = [
        # Pit 1 (x=1216..1408)
        (1216, 320, 192),
        # Pit 2 (x=2112..2368)
        (2112, 320, 256),
        # Pit 3 (x=2880..3136)
        (2880, 320, 256),
    ]

    enemies_list = [
        ("AswangScout_1", "aswang", 620, 260),
        ("AswangScout_2", "aswang", 980, 260),
        ("SkeletonSentry_1", "skeleton", 1580, 255),
        ("AswangProwler_1", "aswang", 1920, 260),
        ("SkeletonGuard_1", "skeleton", 2520, 255),
        ("SkeletonGuard_2", "skeleton", 2780, 255),
        ("AswangElite_1", "aswang", 3360, 260),
        ("SkeletonWarden_1", "skeleton", 3880, 255),
        ("AswangGuardian_1", "aswang", 4420, 260),
        ("SkeletonChampion_1", "skeleton", 4780, 255),
    ]

    build_cave_scene_tscn(
        "level_4_1.tscn", "Level4_1",
        base_cells, platforms, crumble_ledges,
        spike_hazards, enemies_list
    )
    # Also update level_4.tscn for compatibility
    shutil.copyfile(os.path.join(CAVE_DIR, "level_4_1.tscn"), os.path.join(CAVE_DIR, "level_4.tscn"))


def generate_level_4_2():
    """
    Level 4-2: Sunken Lunar Ruins (Anito Shrines & Ancient Stone Bridges)
    Standard: 5120px wide x 360px tall. Floor at y=288. Checkpoint at x=3620.
    """
    base_cells: Dict[Tuple[int, int], Tuple[int, int, int, int]] = {}

    # === BASE GROUND TERRACES (row 9..11, y=288) ===
    # 1. Lunar Forecourt: cols 0..30 (x=0..960)
    paint_ground_block(base_cells, 0, 30, 9, 11, "basalt", 201)
    # Pit 1 Bedrock: cols 31..36 (x=992..1152)
    paint_pit_bedrock(base_cells, 31, 36, "basalt")

    # 2. Sunken Plaza Terrace: cols 37..58 (x=1184..1856)
    paint_ground_block(base_cells, 37, 58, 9, 11, "sapphire", 202)
    # Pit 2 Bedrock: cols 59..65 (x=1888..2080)
    paint_pit_bedrock(base_cells, 59, 65, "basalt")

    # 3. Anito Mirror Promenade: cols 66..88 (x=2112..2816)
    paint_ground_block(base_cells, 66, 88, 9, 11, "basalt", 203)
    # Pit 3 Bedrock: cols 89..95 (x=2848..3040)
    paint_pit_bedrock(base_cells, 89, 95, "basalt")

    # 4. Inner Temple Bastion & Checkpoint (x=3620) & Gate: cols 96..160 (x=3072..5120)
    paint_ground_block(base_cells, 96, 160, 9, 11, "basalt", 204)

    platforms = [
        # Gap 1 (x=960..1184)
        ("bridge",    1072, 240),
        ("island_md", 1160, 215),
        # Plaza High Altar route
        ("sanctuary", 1450, 205),
        ("island_lg", 1720, 180),
        # Gap 2 (x=1856..2112)
        ("bridge",    1984, 235),
        ("sanctuary", 1950, 140), # High ceremonial dais
        # Promenade Route
        ("island_md", 2320, 220),
        ("sanctuary", 2600, 195),
        # Gap 3 (x=2816..3072)
        ("bridge",    2944, 235),
        ("island_md", 3020, 205),
        # Temple Bastion & Checkpoint Approach
        ("sanctuary", 3360, 205),
        ("island_lg", 3850, 215),
        ("bridge",    4200, 220),
        ("sanctuary", 4560, 205),
        ("island_md", 4850, 215),
    ]

    crumble_ledges = [
        (1020, 210),
        (1580, 195),
        (1920, 210),
        (2460, 200),
        (2880, 210),
        (3500, 195),
    ]

    spike_hazards = [
        (960, 320, 224),
        (1856, 320, 256),
        (2816, 320, 256),
    ]

    enemies_list = [
        ("RuinsSentry_1", "skeleton", 520, 255),
        ("RuinsStalker_1", "aswang", 820, 260),
        ("PlazaSentry_1", "skeleton", 1380, 255),
        ("PlazaBrute_1", "aswang", 1750, 260),
        ("PromenadeGuard_1", "skeleton", 2340, 255),
        ("PromenadeStalker_1", "aswang", 2700, 260),
        ("BastionSentry_1", "skeleton", 3350, 255),
        ("ShrineGuardian_1", "aswang", 3880, 260),
        ("InnerGuard_1", "skeleton", 4420, 255),
        ("GateWatcher_1", "aswang", 4800, 260),
    ]

    build_cave_scene_tscn(
        "level_4_2.tscn", "Level4_2",
        base_cells, platforms, crumble_ledges,
        spike_hazards, enemies_list
    )


def generate_level_4_3():
    """
    Level 4-3: The Abyssal Gauntlet (Miniboss Arena Climax)
    Standard: 5120px wide x 360px tall. Floor at y=288. Checkpoint at x=3620.
    Continuous arena floor at x=3760..5080 for fair combat!
    """
    base_cells: Dict[Tuple[int, int], Tuple[int, int, int, int]] = {}

    # === BASE GROUND TERRACES (row 9..11, y=288) ===
    # 1. Gauntlet Foothills: cols 0..26 (x=0..832)
    paint_ground_block(base_cells, 0, 26, 9, 11, "basalt", 301)
    # Pit 1 Bedrock: cols 27..33 (x=864..1056)
    paint_pit_bedrock(base_cells, 27, 33, "basalt")

    # 2. Obsidian Ridge: cols 34..56 (x=1088..1792)
    paint_ground_block(base_cells, 34, 56, 9, 11, "basalt", 302)
    # Pit 2 Bedrock: cols 57..64 (x=1824..2048)
    paint_pit_bedrock(base_cells, 57, 64, "basalt")

    # 3. Crumbling Causeway: cols 65..86 (x=2080..2752)
    paint_ground_block(base_cells, 65, 86, 9, 11, "basalt", 303)
    # Pit 3 Bedrock: cols 87..93 (x=2784..2976)
    paint_pit_bedrock(base_cells, 87, 93, "basalt")

    # 4. Checkpoint (x=3620) & FULL SOLID MINIBOSS ARENA (x=3760..5080) & Exit Gate:
    # cols 94..160 (x=3008..5120) 100% SOLID GROUND
    paint_ground_block(base_cells, 94, 160, 9, 11, "basalt", 304)

    platforms = [
        # Gap 1 (x=832..1088)
        ("bridge",    960, 240),
        ("island_md", 1040, 215),
        # Ridge High Platforms
        ("sanctuary", 1380, 205),
        ("island_lg", 1640, 180),
        # Gap 2 (x=1792..2080)
        ("bridge",    1936, 235),
        ("sanctuary", 1920, 140), # High traverse
        # Causeway Traverse
        ("island_md", 2300, 220),
        ("sanctuary", 2580, 195),
        # Gap 3 (x=2752..3008)
        ("bridge",    2880, 235),
        ("island_md", 2960, 210),
        # Pre-Boss Checkpoint Approach
        ("sanctuary", 3350, 205),
        # ARENA TACTICAL COMBAT PLATFORMS (inside x=3760..5080)
        ("sanctuary", 3960, 210),
        ("island_md", 4220, 165),
        ("bridge",    4450, 195),
        ("island_md", 4680, 165),
        ("sanctuary", 4940, 210),
    ]

    crumble_ledges = [
        (896, 210),
        (1510, 195),
        (1856, 210),
        (2440, 200),
        (2816, 210),
    ]

    spike_hazards = [
        (832, 320, 256),
        (1792, 320, 288),
        (2752, 320, 256),
    ]

    enemies_list = [
        ("GauntletAswang_1", "aswang", 460, 260),
        ("GauntletSentry_1", "skeleton", 720, 255),
        ("RidgeAswang_1", "aswang", 1320, 260),
        ("RidgeSentry_1", "skeleton", 1680, 255),
        ("CausewayAswang_1", "aswang", 2320, 260),
        ("CausewaySentry_1", "skeleton", 2680, 255),
        ("ArenaGuardian_1", "skeleton", 3420, 255),
        ("ArenaStalker_1", "aswang", 3780, 260),
        # Miniboss is spawned dynamically at (4450, 250) by main.gd wire_scene_enemies
    ]

    build_cave_scene_tscn(
        "level_4_3.tscn", "Level4_3",
        base_cells, platforms, crumble_ledges,
        spike_hazards, enemies_list
    )


def generate_level_5():
    """
    Level 5: Bakunawa's Abyss (Climax Boss Encounter)
    Standard: 5120px wide x 360px tall. Floor at y=288. Checkpoint at x=3620.
    Expansive solid obsidian bedrock floor across the entire arena (x=3680..5120)
    for Bakunawa's colossal multi-phase boss fight!
    """
    base_cells: Dict[Tuple[int, int], Tuple[int, int, int, int]] = {}

    # === BASE GROUND TERRACES (row 9..11, y=288) ===
    # 1. Abyssal Descent Gateway: cols 0..24 (x=0..768)
    paint_ground_block(base_cells, 0, 24, 9, 11, "basalt", 401)
    # Pit 1 Bedrock: cols 25..31 (x=800..992)
    paint_pit_bedrock(base_cells, 25, 31, "basalt")

    # 2. Bastion of the Eclipse: cols 32..52 (x=1024..1664)
    paint_ground_block(base_cells, 32, 52, 9, 11, "basalt", 402)
    # Pit 2 Bedrock: cols 53..60 (x=1696..1920)
    paint_pit_bedrock(base_cells, 53, 60, "basalt")

    # 3. The Moon Bridgehead: cols 61..82 (x=1952..2624)
    paint_ground_block(base_cells, 61, 82, 9, 11, "basalt", 403)
    # Pit 3 Bedrock: cols 83..90 (x=2656..2880)
    paint_pit_bedrock(base_cells, 83, 90, "basalt")

    # 4. Checkpoint (x=3620) & BAKUNAWA'S ECLIPSE SANCTUARY ARENA (x=3680..5120):
    # cols 91..160 (x=2912..5120) FULL SOLID OBSIDIAN BEDROCK!
    paint_ground_block(base_cells, 91, 160, 9, 11, "basalt", 404)

    platforms = [
        # Gap 1 (x=768..1024)
        ("bridge",    896, 240),
        ("island_md", 980, 215),
        # Bastion Route
        ("sanctuary", 1280, 210),
        ("island_lg", 1520, 185),
        # Gap 2 (x=1664..1952)
        ("bridge",    1808, 235),
        ("sanctuary", 1780, 140),
        # Bridgehead Route
        ("island_md", 2180, 215),
        ("sanctuary", 2440, 190),
        # Gap 3 (x=2624..2912)
        ("bridge",    2768, 235),
        ("island_md", 2850, 210),
        # Checkpoint Approach
        ("sanctuary", 3250, 205),
        ("island_lg", 3550, 215),
        # BAKUNAWA BOSS ARENA TACTICAL COMBAT PLATFORMS (x=3800..5000)
        ("sanctuary", 3920, 215),
        ("island_md", 4160, 165),
        ("sanctuary", 4450, 195), # Lunar Dais directly over Bakunawa eruption
        ("island_md", 4740, 165),
        ("sanctuary", 4980, 215),
    ]

    crumble_ledges = [
        (832, 210),
        (1400, 195),
        (1728, 210),
        (2320, 200),
        (2688, 210),
    ]

    spike_hazards = [
        (768, 320, 256),
        (1664, 320, 288),
        (2624, 320, 288),
    ]

    enemies_list = [] # Bakunawa is the boss encounter

    build_cave_scene_tscn(
        "level_5.tscn", "Level5",
        base_cells, platforms, crumble_ledges,
        spike_hazards, enemies_list
    )


if __name__ == "__main__":
    build_cave_tileset_tres()
    generate_level_4_1()
    generate_level_4_2()
    generate_level_4_3()
    generate_level_5()
