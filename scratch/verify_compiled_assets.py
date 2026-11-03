import numpy as np
from PIL import Image

im_plat = Image.open("assets/cave_platformer/cave_platforms.png")
im_props = Image.open("assets/cave_platformer/cave_props.png")
im_tiles = Image.open("assets/cave_platformer/cave_rock_tiles.png")

print("Platforms Size:", im_plat.size)
print("Props Size:", im_props.size)
print("Tiles Size:", im_tiles.size)

# Verify platforms
plat_rects = {
    "island_lg": (0, 0, 128, 56),
    "island_md": (128, 0, 224, 48),
    "bridge": (0, 64, 128, 104),
    "crumble": (128, 64, 224, 112),
    "sanctuary": (0, 104, 160, 160),
}

for name, box in plat_rects.items():
    crop = im_plat.crop(box)
    arr = np.array(crop)
    alpha = arr[:,:,3]
    top_row_alpha = alpha[0, :]
    print(f"Platform '{name}' ({box}): max_alpha={alpha.max()}, mean_alpha={alpha.mean():.1f}, top_row_max={top_row_alpha.max()}")
    assert alpha.max() > 100, f"Platform {name} has insufficient alpha!"
    assert top_row_alpha.max() > 50, f"Platform {name} must have pixels at top row y=0 for flush stepping!"

# Verify props
prop_rects = {
    "manunggul": (0, 0, 64, 64),
    "totem": (64, 0, 128, 96),
    "ferns": (128, 0, 192, 64),
    "stalactites": (192, 0, 288, 64),
    "torch": (0, 64, 32, 128),
    "spikes": (64, 64, 160, 96),
    "pearl": (160, 64, 224, 128),
    "pot": (224, 64, 272, 112),
}

for name, box in prop_rects.items():
    crop = im_props.crop(box)
    arr = np.array(crop)
    alpha = arr[:,:,3]
    print(f"Prop '{name}' ({box}): max_alpha={alpha.max()}, mean_alpha={alpha.mean():.1f}")
    assert alpha.max() > 100, f"Prop {name} has insufficient alpha!"

print("ALL ASSET REGIONS VALIDATED SUCCESSFULLY!")
