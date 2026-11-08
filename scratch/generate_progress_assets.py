import os
from PIL import Image

OUT_DIR = r"assets/ui"
os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs("scratch/progress_test", exist_ok=True)

# 12x12 Palette:
# Trans = 0
# Charcoal Outline = 1 (#15171c)
# Slate Dark = 2 (#27323f)
# Slate Mid = 3 (#3a4a5c)
# Slate Light = 4 (#8c9695)
# Stone Light = 5 (#647688)
# Stone Bright = 6 (#98a8b8)
# Bone Dark = 7 (#a8a082)
# Bone Cream = 8 (#d8cfa8)
# Bone Bright = 9 (#f5f0dc)
# Gold Dark = 10 (#96732d)
# Gold Warm = 11 (#c9a24a)
# Gold Bright = 12 (#ecd177)
# Teal Dark = 13 (#294642)
# Teal Mid = 14 (#3f6b66)
# Teal Light = 15 (#98b5a6)
# Teal Bright = 16 (#dff2ea)

COLOR_MAP = {
    0: (0, 0, 0, 0),
    1: (21, 23, 28, 255),       # Charcoal #15171c
    2: (39, 50, 63, 255),       # Slate Dark #27323f
    3: (58, 74, 92, 255),       # Slate Mid #3a4a5c
    4: (140, 150, 149, 255),    # Slate Light #8c9695
    5: (100, 118, 136, 255),    # Stone Light #647688 (lightened lantern stone)
    6: (152, 168, 184, 255),    # Stone Bright #98a8b8
    7: (168, 160, 130, 255),    # Bone Dark #a8a082
    8: (216, 207, 168, 255),    # Bone Cream #d8cfa8
    9: (245, 240, 220, 255),    # Bone Bright #f5f0dc
    10: (150, 115, 45, 255),    # Gold Dark #96732d
    11: (201, 162, 74, 255),    # Gold Warm #c9a24a
    12: (236, 209, 119, 255),   # Gold Bright #ecd177
    13: (41, 70, 66, 255),      # Teal Dark #294642
    14: (63, 107, 102, 255),    # Teal Mid #3f6b66
    15: (152, 181, 166, 255),   # Teal Light #98b5a6
    16: (223, 242, 234, 255),   # Teal Bright #dff2ea
}

def grid_to_image(grid, w, h):
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    for y in range(h):
        for x in range(w):
            idx = grid[y][x]
            im.putpixel((x, y), COLOR_MAP[idx])
    return im

# 1. Haliya Moon Mask - Lit (12x12)
mask_lit_grid = [
    [0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0], # Horn tips
    [0, 1, 12, 1, 0, 0, 0, 0, 1, 12, 1, 0], # Horn curve gold
    [0, 0, 1, 11, 1, 1, 1, 1, 11, 1, 0, 0], # Forehead arch gold
    [0, 1, 1, 11, 12, 12, 12, 12, 11, 1, 1, 0], # Forehead gold band
    [1, 8, 9, 8, 8, 8, 8, 8, 8, 9, 8, 1], # Brow bone
    [1, 9, 8, 1, 8, 8, 8, 8, 1, 8, 9, 1], # Eye slits (1 at x=3, 8)
    [1, 8, 8, 1, 8, 9, 9, 8, 1, 8, 8, 1], # Eyes + nose bridge
    [1, 7, 8, 8, 8, 8, 8, 8, 8, 8, 7, 1], # Cheeks bone
    [0, 1, 7, 8, 8, 1, 1, 8, 8, 7, 1, 0], # Mouth slit at x=5,6
    [0, 1, 7, 7, 8, 8, 8, 8, 7, 7, 1, 0], # Lower jaw
    [0, 0, 1, 7, 7, 8, 8, 7, 7, 1, 0, 0], # Chin
    [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0], # Chin bottom outline
]

# 2. Haliya Moon Mask - Unlit (Remapped to slate, dark slate, slate light, NO GOLD)
mask_unlit_grid = [
    [0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0],
    [0, 1, 4, 1, 0, 0, 0, 0, 1, 4, 1, 0], # Horn tips slate light
    [0, 0, 1, 3, 1, 1, 1, 1, 3, 1, 0, 0], # Slate mid
    [0, 1, 1, 3, 4, 4, 4, 4, 3, 1, 1, 0], # Forehead slate band
    [1, 3, 4, 3, 3, 3, 3, 3, 3, 4, 3, 1], # Face slate mid
    [1, 4, 3, 1, 3, 3, 3, 3, 1, 3, 4, 1], # Eye slits
    [1, 3, 3, 1, 3, 4, 4, 3, 1, 3, 3, 1],
    [1, 2, 3, 3, 3, 3, 3, 3, 3, 3, 2, 1], # Slate dark shading
    [0, 1, 2, 3, 3, 1, 1, 3, 3, 2, 1, 0],
    [0, 1, 2, 2, 3, 3, 3, 3, 2, 2, 1, 0],
    [0, 0, 1, 2, 2, 3, 3, 2, 2, 1, 0, 0],
    [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0],
]

# 3. Shrine Lantern - Lit (12x12) - Frame A (flame centered)
shrine_lit_grid = [
    [0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0], # Finial
    [0, 0, 0, 0, 1, 6, 6, 1, 0, 0, 0, 0], # Roof apex
    [0, 0, 1, 1, 6, 5, 5, 6, 1, 1, 0, 0], # Roof tier
    [0, 1, 6, 5, 5, 5, 5, 5, 5, 6, 1, 0], # Eaves
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], # Eave outline
    [0, 1, 5, 1, 12, 9, 12, 1, 5, 1, 0, 0], # Chamber top + flame tip
    [0, 1, 5, 1, 11, 12, 11, 1, 5, 1, 0, 0], # Chamber + flame body
    [0, 1, 5, 1, 10, 11, 10, 1, 5, 1, 0, 0], # Chamber + flame base
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], # Pedestal capital
    [0, 0, 0, 1, 6, 5, 5, 6, 1, 0, 0, 0], # Stone shaft (visible!)
    [0, 0, 1, 6, 5, 5, 5, 5, 6, 1, 0, 0], # Stepped base
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], # Base outline
]

# 3b. Shrine Lantern - Lit Frame B (flame tip flickers 1px right)
shrine_lit_b_grid = [
    [0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 6, 6, 1, 0, 0, 0, 0],
    [0, 0, 1, 1, 6, 5, 5, 6, 1, 1, 0, 0],
    [0, 1, 6, 5, 5, 5, 5, 5, 5, 6, 1, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 1, 5, 1, 2, 12, 9, 1, 5, 1, 0, 0], # Flame tip shifted right
    [0, 1, 5, 1, 11, 12, 12, 1, 5, 1, 0, 0],
    [0, 1, 5, 1, 10, 11, 11, 1, 5, 1, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 0, 0, 1, 6, 5, 5, 6, 1, 0, 0, 0],
    [0, 0, 1, 6, 5, 5, 5, 5, 6, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
]

# 4. Shrine Lantern - Unlit (12x12) - No flame, dark chamber, light stone body
shrine_unlit_grid = [
    [0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 6, 6, 1, 0, 0, 0, 0],
    [0, 0, 1, 1, 6, 5, 5, 6, 1, 1, 0, 0],
    [0, 1, 6, 5, 5, 5, 5, 5, 5, 6, 1, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 1, 5, 1, 2, 2, 2, 1, 5, 1, 0, 0], # Empty dark chamber
    [0, 1, 5, 1, 2, 2, 2, 1, 5, 1, 0, 0],
    [0, 1, 5, 1, 2, 2, 2, 1, 5, 1, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
    [0, 0, 0, 1, 6, 5, 5, 6, 1, 0, 0, 0],
    [0, 0, 1, 6, 5, 5, 5, 5, 6, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
]

# 5. Crossed Blades - Lit (12x12) - Polished steel & gold hilts
blades_lit_grid = [
    [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], # Blade tips
    [1, 9, 1, 0, 0, 0, 0, 0, 0, 1, 9, 1],
    [0, 1, 9, 1, 0, 0, 0, 0, 1, 9, 1, 0],
    [0, 0, 1, 8, 1, 0, 0, 1, 8, 1, 0, 0],
    [0, 0, 0, 1, 8, 1, 1, 8, 1, 0, 0, 0],
    [0, 0, 0, 0, 1, 12, 12, 1, 0, 0, 0, 0], # Center intersection gold
    [0, 0, 0, 0, 1, 11, 11, 1, 0, 0, 0, 0],
    [0, 0, 1, 11, 1, 11, 11, 1, 11, 1, 0, 0], # Gold crossguards
    [0, 1, 12, 1, 0, 1, 1, 0, 1, 12, 1, 0], # Gold hilts
    [1, 11, 1, 0, 0, 0, 0, 0, 0, 1, 11, 1], # Grips
    [1, 12, 1, 0, 0, 0, 0, 0, 0, 1, 12, 1], # Pommels
    [0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0],
]

# 6. Crossed Blades - Unlit (12x12) - Cold slate & charcoal hilts, NO GOLD
blades_unlit_grid = [
    [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],
    [1, 4, 1, 0, 0, 0, 0, 0, 0, 1, 4, 1], # Slate light edges
    [0, 1, 4, 1, 0, 0, 0, 0, 1, 4, 1, 0],
    [0, 0, 1, 3, 1, 0, 0, 1, 3, 1, 0, 0], # Slate mid blades
    [0, 0, 0, 1, 3, 1, 1, 3, 1, 0, 0, 0],
    [0, 0, 0, 0, 1, 3, 3, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 2, 2, 1, 0, 0, 0, 0], # Center intersection slate dark
    [0, 0, 1, 3, 1, 2, 2, 1, 3, 1, 0, 0],
    [0, 1, 3, 1, 0, 1, 1, 0, 1, 3, 1, 0],
    [1, 2, 1, 0, 0, 0, 0, 0, 0, 1, 2, 1], # Charcoal/dark slate hilts
    [1, 3, 1, 0, 0, 0, 0, 0, 0, 1, 3, 1], # Pommels
    [0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0],
]

# 7. Position Marker A (5x7px) - Teal wisp, tip upright
marker_a_grid = [
    [0, 0, 1, 0, 0],
    [0, 1, 15, 1, 0],
    [1, 15, 16, 1, 0],
    [1, 16, 16, 15, 1],
    [1, 14, 16, 15, 1],
    [1, 14, 14, 14, 1],
    [0, 1, 1, 1, 0],
]

# 8. Position Marker B (5x7px) - Teal wisp, tip flickers 1px right
marker_b_grid = [
    [0, 0, 0, 1, 0],
    [0, 0, 1, 15, 1],
    [0, 1, 15, 16, 1],
    [1, 15, 16, 16, 1],
    [1, 14, 16, 15, 1],
    [1, 14, 14, 14, 1],
    [0, 1, 1, 1, 0],
]

images = {
    "progress_mask_lit.png": grid_to_image(mask_lit_grid, 12, 12),
    "progress_mask_unlit.png": grid_to_image(mask_unlit_grid, 12, 12),
    "progress_shrine_lit.png": grid_to_image(shrine_lit_grid, 12, 12),
    "progress_shrine_lit_b.png": grid_to_image(shrine_lit_b_grid, 12, 12),
    "progress_shrine_unlit.png": grid_to_image(shrine_unlit_grid, 12, 12),
    "progress_blades_lit.png": grid_to_image(blades_lit_grid, 12, 12),
    "progress_blades_unlit.png": grid_to_image(blades_unlit_grid, 12, 12),
    "progress_marker_a.png": grid_to_image(marker_a_grid, 5, 7),
    "progress_marker_b.png": grid_to_image(marker_b_grid, 5, 7),
}

for name, im in images.items():
    p = os.path.join(OUT_DIR, name)
    im.save(p)
    # also save a 16x zoom preview in scratch for inspection
    preview = im.resize((im.size[0] * 16, im.size[1] * 16), Image.Resampling.NEAREST)
    preview.save(os.path.join("scratch/progress_test", "zoom_" + name))
    print(f"Saved {name} ({im.size})")

print("All progress icons generated successfully.")
