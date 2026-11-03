import os
import base64
import struct
from typing import Dict, List, Tuple

def encode_tile_map_data(cells: Dict[Tuple[int, int], Tuple[int, int, int, int]]) -> str:
    buf = bytearray([0, 0])
    for (col, row) in sorted(cells.keys(), key=lambda k: (k[1], k[0])):
        src, ax, ay, alt = cells[(col, row)]
        buf.extend(struct.pack("<hhhhhh", col, row, src, ax, ay, alt))
    return base64.b64encode(bytes(buf)).decode("ascii")

def paint_ground_block(
    base_cells: Dict[Tuple[int, int], Tuple[int, int, int, int]],
    col_start: int,
    col_end: int,
    row_top: int,
    row_bottom: int,
    variant: str = "sapphire",
):
    y_off = 0 if variant == "sapphire" else 6
    for c in range(col_start, col_end + 1):
        is_left = (c == col_start)
        is_right = (c == col_end)
        for r in range(row_top, row_bottom + 1):
            is_top = (r == row_top)
            is_bot = (r == row_bottom)

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
                ax, ay = 1, y_off + 1

            base_cells[(c, r)] = (0, ax, ay, 0)

def test_generate_level_4_1():
    base_cells = {}

    # === CHAMBER 1: The Threshold & Entry Cavern ===
    # Entry Terrace: cols 0..32 (x=0..1024), rows 9..14 (y=288..448)
    paint_ground_block(base_cells, 0, 32, 9, 14, "sapphire")
    # Cavern Ceiling Overhang: cols 0..38 (x=0..1216), rows 0..3 (y=0..96)
    paint_ground_block(base_cells, 0, 38, 0, 3, "sapphire")

    # === CHAMBER 2: The Great Karst Shaft / Vertical Descent ===
    # Left cliff wall of the shaft: cols 30..32 (x=960..1024), rows 15..26 (y=480..832)
    paint_ground_block(base_cells, 30, 32, 15, 26, "sapphire")
    # Right cliff wall / divider: cols 48..51 (x=1536..1632), rows 0..20 (y=0..640)
    paint_ground_block(base_cells, 48, 51, 0, 20, "basalt")

    # === CHAMBER 3: The Sunken Sapphire Grotto ===
    # Grotto Bedrock Floor 1: cols 33..64 (x=1056..2048), rows 27..35 (y=864..1120)
    paint_ground_block(base_cells, 33, 64, 27, 35, "sapphire")
    # Trench 1 Bedrock Pit: cols 65..70 (x=2080..2240), rows 31..35 (y=992..1120)
    paint_ground_block(base_cells, 65, 70, 31, 35, "sapphire")
    # Grotto Sunken Island: cols 71..83 (x=2272..2656), rows 27..35 (y=864..1120)
    paint_ground_block(base_cells, 71, 83, 27, 35, "sapphire")
    # Trench 2 Bedrock Pit: cols 84..88 (x=2688..2816), rows 31..35 (y=992..1120)
    paint_ground_block(base_cells, 84, 88, 31, 35, "sapphire")
    # Grotto Bastion: cols 89..100 (x=2848..3200), rows 27..35 (y=864..1120)
    paint_ground_block(base_cells, 89, 100, 27, 35, "sapphire")
    # Grotto Low Ceiling Overhang: cols 52..86 (x=1664..2752), rows 16..18 (y=512..576)
    paint_ground_block(base_cells, 52, 86, 16, 18, "basalt")

    # === CHAMBER 4: The Ascending Karst Pillar Cathedral ===
    # Abyss Deep Floor below pillars: cols 101..152 (x=3232..4864), rows 32..35 (y=1024..1120)
    paint_ground_block(base_cells, 101, 152, 32, 35, "basalt")
    # Pillar I (Low Stele): cols 105..111 (x=3360..3552), rows 20..31 (y=640..992)
    paint_ground_block(base_cells, 105, 111, 20, 31, "sapphire")
    # Pillar II (Sunken Obelisk): cols 118..125 (x=3776..4000), rows 15..31 (y=480..992)
    paint_ground_block(base_cells, 118, 125, 15, 31, "sapphire")
    # Pillar III (Spire of Libulan): cols 132..139 (x=4224..4448), rows 11..31 (y=352..992)
    paint_ground_block(base_cells, 132, 139, 11, 31, "sapphire")
    # Pillar IV (High Balcony): cols 146..152 (x=4672..4864), rows 8..31 (y=256..992)
    paint_ground_block(base_cells, 146, 152, 8, 31, "sapphire")

    # === CHAMBER 5: The Upper Sanctuary & Exit Portal ===
    # Sanctuary Terrace Floor: cols 153..200 (x=4896..6400), rows 9..14 (y=288..448)
    paint_ground_block(base_cells, 153, 200, 9, 14, "sapphire")
    # Sanctuary High Ceiling: cols 148..200 (x=4736..6400), rows 0..3 (y=0..96)
    paint_ground_block(base_cells, 148, 200, 0, 3, "sapphire")

    b64 = encode_tile_map_data(base_cells)
    print(f"Total tilemap cells: {len(base_cells)}")
    print(f"Base64 length: {len(b64)}")

test_generate_level_4_1()
