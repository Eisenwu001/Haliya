import os
import numpy as np
from PIL import Image

img1_path = r"C:\Users\Lin\.gemini\antigravity\brain\e5c63084-b9ad-4add-8dcb-68444de8a484\philippine_subterranean_cave_tileset_1792544013682.jpg"
img2_path = r"C:\Users\Lin\.gemini\antigravity\brain\e5c63084-b9ad-4add-8dcb-68444de8a484\philippine_cave_platforms_spritesheet_1792544043909.jpg"

im1 = Image.open(img1_path)
im2 = Image.open(img2_path)

print("Image 1 Size:", im1.size, "Mode:", im1.mode)
print("Image 2 Size:", im2.size, "Mode:", im2.mode)

# Save smaller PNG previews in scratch for easy visual examination
im1.save("scratch/ai_cave_tileset_preview.png")
im2.save("scratch/ai_cave_platforms_preview.png")
print("Saved preview images to scratch/")
