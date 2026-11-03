import os
from PIL import Image

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"
pixel_sel = Image.open(os.path.join(artifact_dir, "pass4_full_menu_pixel.png"))
raw_unsel = Image.open(os.path.join(artifact_dir, "pass4_raw_unselected.png")).resize((640, 360), Image.Resampling.NEAREST)

print("--- Selected state y=135..160 ---")
for y in range(135, 160):
    row_chars = []
    for x in range(25, 60):
        r, g, b = pixel_sel.getpixel((x, y))[:3]
        if r > 100 and g > 100:
            row_chars.append(f"#{x}")
    if row_chars:
        print(f"y={y}: {' '.join(row_chars[:10])}")

print("\n--- Unselected state y=135..160 ---")
for y in range(135, 160):
    row_chars = []
    for x in range(25, 60):
        r, g, b = raw_unsel.getpixel((x, y))[:3]
        if r > 100 and g > 100:
            row_chars.append(f"#{x}")
    if row_chars:
        print(f"y={y}: {' '.join(row_chars[:10])}")
