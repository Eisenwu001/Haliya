import os
from PIL import Image

totem_img = Image.open(r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\bahay_kubo\totem_haliya.png")
print("Totem size:", totem_img.size) # (width, height)
# In our setup, totem_target_h = 212, original height is totem_img.height
scale_val = 212.0 / totem_img.height
print(f"Scale: {scale_val:.4f}")

# Let's inspect rows from top to bottom of totem_img to see where features are:
# Crown, Face, Neck, Chest, Arms, Base
for y in range(0, totem_img.height, 10):
    row_pixels = [totem_img.getpixel((x, y)) for x in range(totem_img.width)]
    non_transparent = [p for p in row_pixels if p[3] > 20]
    if non_transparent:
        avg_r = sum(p[0] for p in non_transparent) // len(non_transparent)
        avg_g = sum(p[1] for p in non_transparent) // len(non_transparent)
        avg_b = sum(p[2] for p in non_transparent) // len(non_transparent)
        print(f"orig y={y:3d} (scaled y={(y - totem_img.height//2)*scale_val:6.1f}): count={len(non_transparent):2d}, avg=({avg_r:3d}, {avg_g:3d}, {avg_b:3d})")
