import os
import cv2
import numpy as np
from PIL import Image

im = Image.open(r"C:\Users\Lin\.gemini\antigravity\brain\e5c63084-b9ad-4add-8dcb-68444de8a484\philippine_subterranean_cave_tileset_1792544013682.jpg").convert("RGBA")
arr = np.array(im)

out_dir = "scratch/extracted_tileset_1"
os.makedirs(out_dir, exist_ok=True)

# Save high-res individual cells
for r in range(4):
    for c in range(4):
        cell = im.crop((c * 256, r * 256, (c + 1) * 256, (r + 1) * 256))
        cell.save(f"{out_dir}/cell_{r}_{c}.png")

print("Saved all 16 cells of Tileset 1 to scratch/extracted_tileset_1/")
