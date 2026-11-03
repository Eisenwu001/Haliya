from PIL import Image
import numpy as np

snap1 = Image.open('snapshot_rice_field_2_1.png')
print("snap1 size:", snap1.size)
# Crop center around carabao and player:
w, h = snap1.size
crop_carabao = snap1.crop((w // 2 - 300, h // 2 - 200, w // 2 + 300, h // 2 + 200))
crop_carabao.save("scratch/verify_snap1_carabao.png")

# Check bottom of snap1: are there any black voids in the dirt?
# Dirt surface is at y ~ 288 (scaled). The bottom of the screen should be solid textured dirt, NOT pure black [0, 0, 0]!
arr = np.array(snap1)
bottom_strip = arr[h - 100:h, :, :]
is_pure_black = (bottom_strip[:, :, 0] == 0) & (bottom_strip[:, :, 1] == 0) & (bottom_strip[:, :, 2] == 0)
print(f"Bottom 100 rows pure black fraction: {is_pure_black.sum() / is_pure_black.size * 100:.2f}%")
print("Bottom strip average color:", bottom_strip.mean(axis=(0, 1)))

# Crop bottom-middle to inspect dirt fill:
crop_dirt = snap1.crop((w // 2 - 300, h - 300, w // 2 + 300, h))
crop_dirt.save("scratch/verify_snap1_dirt.png")

print("Saved scratch/verify_snap1_carabao.png and scratch/verify_snap1_dirt.png")
