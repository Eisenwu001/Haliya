#!/usr/bin/env python3
"""
Build Rice Field Levels Generator for Haliya: Mask of Sorrows (5-Level Stage 2 Overhaul)
Generates Levels 2-1, 2-2, 2-3, 2-4, and 2-5 with:
- Standard 2D platformer dimensions (5120px x 360px), camera y=180.0
- Base floor at y=288.0 (row 9..23), 100% solid seamless interior down to y=768px
- Stepped earthen terraces (pilapil) up to 3 tiers high (Row 8 y=256, Row 7 y=224, Row 6 y=192)
- Authentic 3-tier jumpable Bahay Kubo stilt houses (porch y=-48, eaves y=-96, ridge y=-138)
- Bamboo Water Flumes (Patubig) with jumpable water channel (y=-46) & splash particles
- Interactive Mud Puddle Hazards bridged by elevated Pilapil Stone Dikes
- Interactive Carabaos (Kalabaw) with jumpable back platform & living squish response
- Zero duplicate sibling node names and zero stacked redundant puddles
- Climactic Mayon Vanguard Miniboss EXCLUSIVELY in Level 2-5 (no clones in 2-3 or 2-4)
"""

import base64
import os
import struct
from typing import Dict, List, Tuple

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RICE_DIR = os.path.join(BASE_DIR, "scenes", "rice_field")
os.makedirs(RICE_DIR, exist_ok=True)


def encode_tile_map_data(cells: Dict[Tuple[int, int], Tuple[int, int, int, int]]) -> str:
    buf = bytearray([0, 0])
    for (col, row) in sorted(cells.keys(), key=lambda k: (k[1], k[0])):
        src, ax, ay, alt = cells[(col, row)]
        buf.extend(struct.pack("<hhhhhh", col, row, src, ax, ay, alt))
    return base64.b64encode(bytes(buf)).decode("ascii")


def paint_base_ground(
    cells: Dict[Tuple[int, int], Tuple[int, int, int, int]],
    total_cols: int = 160,
    base_row: int = 9,
    bottom_row: int = 23
):
    for c in range(total_cols):
        cells[(c, base_row)] = (0, 1, 0, 0) # Grass top
        for r in range(base_row + 1, bottom_row + 1):
            cells[(c, r)] = (0, 1, 1, 0) # Solid dirt fill


def paint_terrace(
    cells: Dict[Tuple[int, int], Tuple[int, int, int, int]],
    col_start: int,
    col_end: int,
    top_row: int,
    base_row: int = 9,
    bottom_row: int = 23
):
    left_rows = [r for (c, r) in cells.keys() if c == col_start - 1]
    left_neighbor_top = min(left_rows) if left_rows else base_row
    right_rows = [r for (c, r) in cells.keys() if c == col_end + 1]
    right_neighbor_top = min(right_rows) if right_rows else base_row

    for c in range(col_start, col_end + 1):
        if c == col_start:
            cells[(c, top_row)] = (0, 0, 0, 0)
        elif c == col_end:
            cells[(c, top_row)] = (0, 2, 0, 0)
        else:
            cells[(c, top_row)] = (0, 1, 0, 0)

        for r in range(top_row + 1, bottom_row + 1):
            if c == col_start:
                if r < left_neighbor_top:
                    cells[(c, r)] = (0, 0, 1, 0)
                else:
                    cells[(c, r)] = (0, 1, 1, 0)
            elif c == col_end:
                if r < right_neighbor_top:
                    cells[(c, r)] = (0, 2, 1, 0)
                else:
                    cells[(c, r)] = (0, 1, 1, 0)
            else:
                cells[(c, r)] = (0, 1, 1, 0)


def generate_level_tscn(
    level_name: str,
    uid_str: str,
    terraces: List[Tuple[int, int, int]],           # (col_start, col_end, top_row)
    carabaos: List[Tuple[float, float, bool]],      # (x, y, facing_left)
    kubos: List[Tuple[float, float]],               # (x, y)
    flumes: List[Tuple[float, float]],              # (x, y)
    dikes: List[Tuple[float, float]],               # (x, y) PilapilDikeProp
    mud_hazards: List[Tuple[float, float]],         # (x, y) MudPuddleHazard Area2D
    deco_puddles: List[Tuple[float, float]],        # (x, y) Decorative Sprite2D
    egrets: List[Tuple[float, float, bool]],        # (x, y, facing_left)
    stalks: List[Tuple[float, float]],              # (x, y)
    pots: List[Tuple[float, float]],                # (x, y)
    torches: List[Tuple[float, float, int, float]], # (x, y, type, energy)
    enemies: List[Tuple[str, str, float, float]],   # (node_name, ext_id, x, y)
    out_file: str
):
    cells: Dict[Tuple[int, int], Tuple[int, int, int, int]] = {}
    paint_base_ground(cells, total_cols=160, base_row=9, bottom_row=23)

    for col_s, col_e, top_r in terraces:
        paint_terrace(cells, col_s, col_e, top_r, base_row=9, bottom_row=23)

    tile_data_str = encode_tile_map_data(cells)

    lines = [
        f'[gd_scene format=4 uid="{uid_str}"]',
        '',
        '[ext_resource type="TileSet" uid="uid://caqafd7pfb2tm" path="res://scenes/tileset.tres" id="1_tileset"]',
        '[ext_resource type="Script" path="res://scripts/aswang.gd" id="2_aswang"]',
        '[ext_resource type="Script" path="res://scripts/corrupted_farmer.gd" id="3_farmer"]',
        '[ext_resource type="Script" path="res://scripts/mayon_vanguard_miniboss.gd" id="5_miniboss"]',
        '[ext_resource type="Script" path="res://scripts/rice_field_carabao.gd" id="6_carabao"]',
        '[ext_resource type="Script" path="res://scripts/bahay_kubo_prop.gd" id="7_kubo"]',
        '[ext_resource type="Script" path="res://scripts/bamboo_flume_prop.gd" id="8_flume"]',
        '[ext_resource type="Script" path="res://scripts/ambient_egret.gd" id="9_egret"]',
        '[ext_resource type="Script" path="res://scripts/swaying_rice_stalks.gd" id="10_stalks"]',
        '[ext_resource type="Script" path="res://scripts/sky_bird_flock.gd" id="11_skyflock"]',
        '[ext_resource type="Script" path="res://scripts/palayok_pot.gd" id="12_pot"]',
        '[ext_resource type="Script" path="res://scripts/environment_torch.gd" id="13_torch"]',
        '[ext_resource type="Texture2D" path="res://assets/rice_field/mud_puddle.png" id="14_puddle_tex"]',
        '[ext_resource type="Script" path="res://scripts/pilapil_dike_prop.gd" id="15_pilapil"]',
        '[ext_resource type="Script" path="res://scripts/mud_puddle_hazard.gd" id="16_mud_hazard"]',
        '',
        f'[node name="{level_name}" type="Node2D"]',
        '',
        '[node name="WaterBackground" type="TileMapLayer" parent="."]',
        'z_index = -1',
        'tile_set = ExtResource("1_tileset")',
        'collision_enabled = false',
        '',
        '[node name="BaseGround" type="TileMapLayer" parent="."]',
        f'tile_map_data = PackedByteArray("{tile_data_str}")',
        'tile_set = ExtResource("1_tileset")',
        '',
        '[node name="ForegroundDecor" type="TileMapLayer" parent="."]',
        'z_index = 1',
        'tile_set = ExtResource("1_tileset")',
        'collision_enabled = false',
        '',
        '[node name="SkyBirdFlock" type="Node2D" parent="."]',
        'script = ExtResource("11_skyflock")',
        '',
        '[node name="Props" type="Node2D" parent="."]',
        '',
    ]

    # 1. Decorative Mud Puddles (embedded flush into Floor Tiles1.png at z_index = 1)
    for idx, (pux, puy) in enumerate(deco_puddles):
        lines.extend([
            f'[node name="DecoPuddle_{idx+1}" type="Sprite2D" parent="Props"]',
            f'position = Vector2({pux:.1f}, {puy:.1f})',
            'texture = ExtResource("14_puddle_tex")',
            'texture_filter = 0',
            'offset = Vector2(0.0, 6.0)',
            'z_index = 1',
            '',
        ])

    # 2. Interactive Mud Puddle Hazards (Area2D)
    for idx, (mhx, mhy) in enumerate(mud_hazards):
        lines.extend([
            f'[node name="MudHazard_{idx+1}" type="Area2D" parent="Props"]',
            f'position = Vector2({mhx:.1f}, {mhy:.1f})',
            'script = ExtResource("16_mud_hazard")',
            '',
        ])

    # 3. Pilapil Stone & Earthen Dike Platforms (StaticBody2D)
    for idx, (dkx, dky) in enumerate(dikes):
        lines.extend([
            f'[node name="PilapilDike_{idx+1}" type="StaticBody2D" parent="Props"]',
            f'position = Vector2({dkx:.1f}, {dky:.1f})',
            'script = ExtResource("15_pilapil")',
            '',
        ])

    # 4. Carabaos (AnimatableBody2D - spawns its own internal mud puddle)
    for idx, (cx, cy, face_left) in enumerate(carabaos):
        lines.extend([
            f'[node name="Carabao_{idx+1}" type="AnimatableBody2D" parent="Props"]',
            f'position = Vector2({cx:.1f}, {cy:.1f})',
            'script = ExtResource("6_carabao")',
            f'facing_left = {"true" if face_left else "false"}',
            '',
        ])

    # 5. Bahay Kubo Stilt Houses (StaticBody2D with 3-tier platforms)
    for idx, (kx, ky) in enumerate(kubos):
        lines.extend([
            f'[node name="BahayKubo_{idx+1}" type="StaticBody2D" parent="Props"]',
            f'position = Vector2({kx:.1f}, {ky:.1f})',
            'script = ExtResource("7_kubo")',
            '',
        ])

    # 6. Bamboo Water Flumes (StaticBody2D with water channel platform & splash particles)
    for idx, (fx, fy) in enumerate(flumes):
        lines.extend([
            f'[node name="BambooFlume_{idx+1}" type="StaticBody2D" parent="Props"]',
            f'position = Vector2({fx:.1f}, {fy:.1f})',
            'script = ExtResource("8_flume")',
            '',
        ])

    # 7. White Egrets (Tagak)
    for idx, (ex, ey, face_left) in enumerate(egrets):
        lines.extend([
            f'[node name="Egret_{idx+1}" type="Node2D" parent="Props"]',
            f'position = Vector2({ex:.1f}, {ey:.1f})',
            'script = ExtResource("9_egret")',
            f'facing_left = {"true" if face_left else "false"}',
            '',
        ])

    # 8. Swaying Rice Stalks
    for idx, (sx, sy) in enumerate(stalks):
        lines.extend([
            f'[node name="RiceStalks_{idx+1}" type="Node2D" parent="Props"]',
            f'position = Vector2({sx:.1f}, {sy:.1f})',
            'script = ExtResource("10_stalks")',
            '',
        ])

    # 9. Breakable Palayok Pots
    for idx, (px, py) in enumerate(pots):
        lines.extend([
            f'[node name="PalayokPot_{idx+1}" type="StaticBody2D" parent="Props"]',
            f'position = Vector2({px:.1f}, {py:.1f})',
            'script = ExtResource("12_pot")',
            '',
        ])

    # 10. Bamboo Torches & Hanging Lanterns
    for idx, (tx, ty, t_type, energy) in enumerate(torches):
        lines.extend([
            f'[node name="Torch_{idx+1}" type="Node2D" parent="Props"]',
            f'position = Vector2({tx:.1f}, {ty:.1f})',
            'script = ExtResource("13_torch")',
            f'torch_type = {t_type}',
            f'light_energy = {energy:.2f}',
            '',
        ])

    lines.extend([
        '[node name="Enemies" type="Node2D" parent="."]',
        '',
    ])

    for (ename, ext_id, ex, ey) in enemies:
        lines.extend([
            f'[node name="{ename}" type="CharacterBody2D" parent="Enemies"]',
            f'position = Vector2({ex:.1f}, {ey:.1f})',
            f'script = ExtResource("{ext_id}")',
            '',
        ])

    with open(out_file, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines))
    print(f"Generated {out_file} ({len(enemies)} enemies, {len(kubos)} Bahay Kubos, {len(flumes)} Flumes, {len(dikes)} Dikes)")


def build_all():
    # ═══════════════════════════════════════════════════════════════════════════
    # LEVEL 2-1: "Emerald Terraces" (Morning Golden Sun, Intro to Terraces & Flumes)
    # ═══════════════════════════════════════════════════════════════════════════
    l21_terraces = [
        (22, 38, 8),   # x = 704..1216 (y = 256.0)
        (55, 76, 8),   # x = 1760..2432 (y = 256.0)
        (62, 70, 7),   # x = 1984..2240 (y = 224.0, Upper Terrace)
        (92, 114, 8),  # x = 2944..3648 (y = 256.0)
        (122, 138, 8), # x = 3904..4416 (y = 256.0)
    ]
    l21_carabaos = [
        (520.0, 288.0, True),
        (1620.0, 288.0, False),
        (3320.0, 256.0, True),
    ]
    l21_kubos = []
    l21_flumes = []
    l21_mud_hazards = [
        (1440.0, 288.0),
        (2780.0, 288.0),
    ]
    l21_dikes = []
    l21_deco_puddles = [
        (4180.0, 256.0),
    ]
    l21_egrets = [
        (320.0, 288.0, True),
        (850.0, 256.0, False),
        (1560.0, 288.0, True),
        (2100.0, 224.0, False),
        (3120.0, 256.0, True),
        (4120.0, 256.0, False),
    ]
    l21_stalks = [
        (260.0, 288.0), (440.0, 288.0), (620.0, 288.0),
        (800.0, 256.0), (1000.0, 256.0), (1320.0, 288.0),
        (1840.0, 256.0), (2140.0, 224.0), (2400.0, 288.0),
        (3050.0, 256.0), (3480.0, 256.0), (3700.0, 288.0),
        (4020.0, 256.0), (4320.0, 256.0), (4680.0, 288.0),
    ]
    l21_pots = [
        (1140.0, 256.0), # On first terrace
        (2040.0, 224.0), # Upper Terrace
        (2580.0, 288.0), # Grounded in valley
        (3740.0, 288.0),
    ]
    l21_torches = []
    l21_enemies = [
        ("CorruptedFarmer_01", "3_farmer", 820.0, 256.0),
        ("Aswang_01", "2_aswang", 1280.0, 288.0),
        ("CorruptedFarmer_02", "3_farmer", 1820.0, 256.0),
        ("CorruptedFarmer_03", "3_farmer", 2080.0, 224.0),
        ("Aswang_02", "2_aswang", 2360.0, 256.0),
        ("CorruptedFarmer_04", "3_farmer", 3040.0, 256.0),
        ("CorruptedFarmer_05", "3_farmer", 4080.0, 256.0),
    ]
    generate_level_tscn(
        "Level_2_1", "uid://dcmdcoujgmub",
        l21_terraces, l21_carabaos, l21_kubos, l21_flumes, l21_dikes,
        l21_mud_hazards, l21_deco_puddles, l21_egrets, l21_stalks, l21_pots, l21_torches, l21_enemies,
        os.path.join(RICE_DIR, "level_2_1.tscn")
    )

    # ═══════════════════════════════════════════════════════════════════════════
    # LEVEL 2-2: "Stilt Farmstead" (4 Authentic Bahay Kubo Stilt Huts & Rooftop Highway)
    # ═══════════════════════════════════════════════════════════════════════════
    l22_terraces = [
        (18, 34, 8),   # x = 576..1088 (y = 256.0)
        (48, 84, 8),   # x = 1536..2688 (y = 256.0)
        (56, 76, 7),   # x = 1792..2432 (y = 224.0, Village Rise)
        (98, 126, 8),  # x = 3136..4032 (y = 256.0, Granary Terrace)
        (134, 148, 8), # x = 4288..4736 (y = 256.0)
    ]
    l22_carabaos = [
        (960.0, 256.0, True),
        (2560.0, 256.0, False),
    ]
    l22_kubos = []
    l22_flumes = []
    l22_mud_hazards = [
        (1260.0, 288.0),
        (2860.0, 288.0),
        (4176.0, 288.0),
    ]
    l22_dikes = []
    l22_deco_puddles = [
        (4480.0, 256.0),
    ]
    l22_egrets = [
        (420.0, 288.0, True),
        (1500.0, 288.0, False),
        (2360.0, 224.0, True),
        (3920.0, 256.0, False),
    ]
    l22_stalks = [
        (280.0, 288.0), (480.0, 288.0), (880.0, 256.0),
        (1860.0, 224.0), (2320.0, 224.0), (3040.0, 288.0),
        (3280.0, 256.0), (3760.0, 256.0), (3960.0, 256.0),
        (4380.0, 256.0), (4620.0, 256.0), (4840.0, 288.0),
    ]
    l22_pots = [
        (740.0, 256.0),
        (2120.0, 224.0),
        (3520.0, 256.0),
        (4560.0, 256.0),
    ]
    l22_torches = [
        (1120.0, 288.0, 0, 0.85),
        (2860.0, 288.0, 0, 0.85),
        (4240.0, 288.0, 0, 0.85),
    ]
    l22_enemies = [
        ("CorruptedFarmer_01", "3_farmer", 860.0, 256.0),
        ("CorruptedFarmer_02", "3_farmer", 1040.0, 256.0),
        ("Aswang_01", "2_aswang", 1460.0, 288.0),
        ("Aswang_02", "2_aswang", 1840.0, 224.0),
        ("CorruptedFarmer_03", "3_farmer", 2240.0, 224.0),
        ("CorruptedFarmer_04", "3_farmer", 2620.0, 256.0),
        ("Aswang_03", "2_aswang", 3220.0, 256.0),
        ("CorruptedFarmer_05", "3_farmer", 3740.0, 256.0),
        ("CorruptedFarmer_06", "3_farmer", 4420.0, 256.0),
    ]
    generate_level_tscn(
        "Level_2_2", "uid://c0ricefield22",
        l22_terraces, l22_carabaos, l22_kubos, l22_flumes, l22_dikes,
        l22_mud_hazards, l22_deco_puddles, l22_egrets, l22_stalks, l22_pots, l22_torches, l22_enemies,
        os.path.join(RICE_DIR, "level_2_2.tscn")
    )

    # ═══════════════════════════════════════════════════════════════════════════
    # LEVEL 2-3: "The Mayon Crossing" (Sunset Irrigation Gorge & Flooded Channels)
    # Note: NO miniboss here — Miniboss is the climax of Level 2-5!
    # ═══════════════════════════════════════════════════════════════════════════
    l23_terraces = [
        (20, 36, 8),   # x = 640..1152 (y = 256.0)
        (50, 74, 8),   # x = 1600..2368 (y = 256.0)
        (56, 68, 7),   # x = 1792..2176 (y = 224.0)
        (88, 112, 8),  # x = 2816..3584 (y = 256.0)
        (94, 106, 7),  # x = 3008..3392 (y = 224.0)
        (124, 146, 8), # x = 3968..4672 (y = 256.0)
    ]
    l23_carabaos = [
        (520.0, 288.0, True),
        (2580.0, 288.0, False),
    ]
    l23_kubos = []
    l23_flumes = []
    l23_mud_hazards = [
        (1280.0, 288.0),
        (1480.0, 288.0),
        (2680.0, 288.0),
        (3760.0, 288.0),
    ]
    l23_dikes = []
    l23_deco_puddles = [
        (920.0, 256.0),
    ]
    l23_egrets = [
        (360.0, 288.0, True),
        (1020.0, 256.0, False),
        (3180.0, 224.0, True),
    ]
    l23_stalks = [
        (280.0, 288.0), (740.0, 256.0), (1060.0, 256.0),
        (1680.0, 256.0), (2260.0, 256.0), (2900.0, 256.0),
        (3280.0, 224.0), (3500.0, 256.0), (4060.0, 256.0),
        (4560.0, 256.0), (4820.0, 288.0),
    ]
    l23_pots = [
        (980.0, 256.0),
        (1980.0, 224.0),
        (3200.0, 224.0),
        (4280.0, 256.0),
    ]
    l23_torches = [
        (680.0, 256.0, 0, 0.90),
        (2860.0, 256.0, 0, 0.95),
        (3540.0, 256.0, 0, 0.95),
        (4720.0, 288.0, 0, 0.95),
    ]
    l23_enemies = [
        ("CorruptedFarmer_01", "3_farmer", 780.0, 256.0),
        ("CorruptedFarmer_02", "3_farmer", 1060.0, 256.0),
        ("Aswang_01", "2_aswang", 1360.0, 288.0),
        ("CorruptedFarmer_03", "3_farmer", 1720.0, 256.0),
        ("Aswang_02", "2_aswang", 2060.0, 224.0),
        ("CorruptedFarmer_04", "3_farmer", 2280.0, 256.0),
        ("Aswang_03", "2_aswang", 2920.0, 256.0),
        ("CorruptedFarmer_05", "3_farmer", 3160.0, 224.0),
        ("Aswang_04", "2_aswang", 3840.0, 288.0),
        ("CorruptedFarmer_06", "3_farmer", 4460.0, 256.0),
    ]
    generate_level_tscn(
        "Level_2_3", "uid://c0ricefield23",
        l23_terraces, l23_carabaos, l23_kubos, l23_flumes, l23_dikes,
        l23_mud_hazards, l23_deco_puddles, l23_egrets, l23_stalks, l23_pots, l23_torches, l23_enemies,
        os.path.join(RICE_DIR, "level_2_3.tscn")
    )

    # ═══════════════════════════════════════════════════════════════════════════
    # LEVEL 2-4: "The Caldera Foothills" (3-Tier High-Altitude Volcanic Terraces)
    # Features Row 6 (y = 192.0) high-altitude ridge terraces & mud-trench gauntlets
    # ═══════════════════════════════════════════════════════════════════════════
    l24_terraces = [
        (16, 44, 8),   # x = 512..1408 (y = 256.0)
        (22, 38, 7),   # x = 704..1216 (y = 224.0)
        (26, 34, 6),   # x = 832..1088 (y = 192.0, High Summit Ridge 1)
        (58, 92, 8),   # x = 1856..2944 (y = 256.0)
        (64, 86, 7),   # x = 2048..2752 (y = 224.0)
        (70, 80, 6),   # x = 2240..2560 (y = 192.0, High Summit Ridge 2)
        (108, 144, 8), # x = 3456..4608 (y = 256.0)
        (116, 136, 7), # x = 3712..4352 (y = 224.0)
    ]
    l24_carabaos = [
        (1620.0, 288.0, True),
        (3180.0, 288.0, False),
    ]
    l24_kubos = []
    l24_flumes = []
    l24_mud_hazards = [
        (1530.0, 288.0),
        (1750.0, 288.0),
        (3080.0, 288.0),
        (3350.0, 288.0),
    ]
    l24_dikes = []
    l24_deco_puddles = [
        (4760.0, 288.0),
    ]
    l24_egrets = [
        (340.0, 288.0, True),
        (2140.0, 224.0, False),
    ]
    l24_stalks = [
        (300.0, 288.0), (600.0, 256.0), (1140.0, 224.0),
        (1940.0, 256.0), (2640.0, 224.0), (2860.0, 256.0),
        (3560.0, 256.0), (3820.0, 224.0), (4260.0, 224.0),
        (4500.0, 256.0), (4840.0, 288.0),
    ]
    l24_pots = [
        (960.0, 192.0),  # On Summit Ridge 1
        (2400.0, 192.0), # Atop High Summit Ridge 2
        (3180.0, 236.0), # Above Carabao_2
        (4032.0, 224.0), # On Foothill Terrace
    ]
    l24_torches = [
        (560.0, 256.0, 0, 1.00),
        (1900.0, 256.0, 0, 1.00),
        (2300.0, 192.0, 0, 1.05),
        (2880.0, 256.0, 0, 1.00),
        (3520.0, 256.0, 0, 1.00),
        (4560.0, 256.0, 0, 1.00),
    ]
    l24_enemies = [
        ("CorruptedFarmer_01", "3_farmer", 620.0, 256.0),
        ("Aswang_01", "2_aswang", 800.0, 224.0),
        ("CorruptedFarmer_02", "3_farmer", 1120.0, 224.0),
        ("CorruptedFarmer_03", "3_farmer", 1320.0, 256.0),
        ("Aswang_02", "2_aswang", 1960.0, 256.0),
        ("CorruptedFarmer_04", "3_farmer", 2160.0, 224.0),
        ("CorruptedFarmer_05", "3_farmer", 2480.0, 192.0),
        ("Aswang_03", "2_aswang", 2700.0, 224.0),
        ("CorruptedFarmer_06", "3_farmer", 3600.0, 256.0),
        ("Aswang_04", "2_aswang", 3880.0, 224.0),
        ("CorruptedFarmer_07", "3_farmer", 4420.0, 256.0),
    ]
    generate_level_tscn(
        "Level_2_4", "uid://c0ricefield24",
        l24_terraces, l24_carabaos, l24_kubos, l24_flumes, l24_dikes,
        l24_mud_hazards, l24_deco_puddles, l24_egrets, l24_stalks, l24_pots, l24_torches, l24_enemies,
        os.path.join(RICE_DIR, "level_2_4.tscn")
    )

    # ═══════════════════════════════════════════════════════════════════════════
    # LEVEL 2-5: "The Burning Kiln Village" (Stage 2 Climax & Mayon Vanguard Arena)
    # Section 1 (x = 0..3520): Fortified Kiln Village Ascent
    # Sanctuary (x = 3580..3950): Ancestral Checkpoint Shrine (x=3620) & Pot Cache
    # Section 2 (x = 3980..5080): Flat Unobstructed Mayon Vanguard Boss Arena
    # ═══════════════════════════════════════════════════════════════════════════
    l25_terraces = [
        (16, 34, 8),   # x = 512..1088 (y = 256.0)
        (46, 72, 8),   # x = 1472..2304 (y = 256.0)
        (52, 66, 7),   # x = 1664..2112 (y = 224.0, Kiln Village Heights)
        (84, 108, 8),  # x = 2688..3456 (y = 256.0, Final Pre-Arena Bastion)
        # Columns 110..159 (x = 3520..5120) are 100% flat Row 9 (y = 288.0) for Shrine & Vanguard Arena!
    ]
    l25_carabaos = [
        (1280.0, 288.0, True),
        (2500.0, 288.0, False),
    ]
    l25_kubos = []
    l25_flumes = []
    l25_mud_hazards = [
        (1200.0, 288.0),
        (2420.0, 288.0),
        (2600.0, 288.0),
    ]
    l25_dikes = []
    l25_deco_puddles = [
        (380.0, 288.0),
    ]
    l25_egrets = [
        (320.0, 288.0, True),
    ]
    l25_stalks = [
        (260.0, 288.0), (600.0, 256.0), (980.0, 256.0),
        (1560.0, 256.0), (2180.0, 256.0), (2780.0, 256.0),
        (3340.0, 256.0), (3540.0, 288.0),
    ]
    l25_pots = [
        (800.0, 256.0),
        (1880.0, 224.0),
        # Pre-Arena Sanctuary Healing Cache (right next to Ancestral Shrine at x=3620)
        (3680.0, 288.0),
        (3720.0, 288.0),
        (3760.0, 288.0),
    ]
    l25_torches = [
        (540.0, 256.0, 0, 1.05),
        (1520.0, 256.0, 0, 1.05),
        (2740.0, 256.0, 0, 1.05),
        (3400.0, 256.0, 0, 1.05),
        # Vanguard Arena Perimeter Torches
        (3960.0, 288.0, 0, 1.25),
        (4450.0, 288.0, 0, 1.25),
        (4980.0, 288.0, 0, 1.25),
    ]
    l25_enemies = [
        ("CorruptedFarmer_01", "3_farmer", 660.0, 256.0),
        ("CorruptedFarmer_02", "3_farmer", 960.0, 256.0),
        ("Aswang_01", "2_aswang", 1360.0, 288.0),
        ("CorruptedFarmer_03", "3_farmer", 1600.0, 256.0),
        ("Aswang_02", "2_aswang", 1820.0, 224.0),
        ("CorruptedFarmer_04", "3_farmer", 2040.0, 224.0),
        ("Aswang_03", "2_aswang", 2820.0, 256.0),
        ("CorruptedFarmer_05", "3_farmer", 3160.0, 256.0),
        ("Aswang_04", "2_aswang", 3360.0, 256.0),
        # CLIMAX MINIBOSS: Mayon Flame Vanguard
        ("MayonVanguardMiniboss", "5_miniboss", 4450.0, 250.0),
    ]
    generate_level_tscn(
        "Level_2_5", "uid://c0ricefield25",
        l25_terraces, l25_carabaos, l25_kubos, l25_flumes, l25_dikes,
        l25_mud_hazards, l25_deco_puddles, l25_egrets, l25_stalks, l25_pots, l25_torches, l25_enemies,
        os.path.join(RICE_DIR, "level_2_5.tscn")
    )


if __name__ == "__main__":
    build_all()
    print("All 5 Rice Field levels (2-1 to 2-5) generated successfully!")
