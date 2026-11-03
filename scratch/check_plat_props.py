import os
import re
import numpy as np
from PIL import Image

plat_img = Image.open('assets/cave_platformer/cave_platforms.png')
props_img = Image.open('assets/cave_platformer/cave_props.png')
tiles_img = Image.open('assets/cave_platformer/cave_rock_tiles.png')

print("=== CAVE_PLATFORMS.PNG ===")
# Platforms defined in build_cave_levels.py:
# island_lg: Rect2(0, 0, 128, 56)
# island_md: Rect2(128, 0, 96, 48)
# bridge: Rect2(0, 64, 128, 40)
# sanctuary: Rect2(0, 104, 160, 56)
# crumble: Rect2(128, 64, 96, 48)

specs = [
    ("island_lg", (0, 0, 128, 56)),
    ("island_md", (128, 0, 96, 48)),
    ("bridge", (0, 64, 128, 40)),
    ("crumble", (128, 64, 96, 48)),
    ("sanctuary", (0, 104, 160, 56)),
]

for name, (rx, ry, rw, rh) in specs:
    crop = plat_img.crop((rx, ry, rx + rw, ry + rh))
    arr = np.array(crop)
    alpha = arr[:, :, 3]
    opaque_ys, opaque_xs = np.where(alpha > 15)
    if len(opaque_ys) == 0:
        print(f"{name}: COMPLETELY EMPTY!")
    else:
        print(f"{name}: bounds y=[{opaque_ys.min()}..{opaque_ys.max()}], x=[{opaque_xs.min()}..{opaque_xs.max()}]")

print("\n=== CAVE_PROPS.PNG ===")
# In build_cave_levels.py:
# spire/stele/lamp: Rect2(0, 0, 64, 96)
# flora: Rect2(0, 96, 64, 64)
# stalactite: Rect2(224, 96, 96, 64)
# geode (in cave_crystal_geode.gd? let's check)
props_specs = [
    ("spire", (0, 0, 64, 96)),
    ("flora", (0, 96, 64, 64)),
    ("stalactite", (224, 96, 96, 64)),
    ("pogo", (96, 0, 64, 48)),
    ("spikes", (160, 0, 96, 32)),
    ("geode_cyan", (64, 0, 64, 64)),
    ("geode_amethyst", (128, 0, 64, 64)),
]
for name, (rx, ry, rw, rh) in props_specs:
    crop = props_img.crop((rx, ry, rx + rw, ry + rh))
    arr = np.array(crop)
    alpha = arr[:, :, 3]
    opaque_ys, opaque_xs = np.where(alpha > 15)
    if len(opaque_ys) == 0:
        print(f"{name}: COMPLETELY EMPTY!")
    else:
        print(f"{name}: bounds y=[{opaque_ys.min()}..{opaque_ys.max()}], x=[{opaque_xs.min()}..{opaque_xs.max()}]")
