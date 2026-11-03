import os
from PIL import Image

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"
pixel_sel = Image.open(os.path.join(artifact_dir, "pass4_full_menu_pixel.png"))

print("--- Column 483 scan (center of Totem) ---")
for y in range(70, 360, 5):
    r, g, b = pixel_sel.getpixel((483, y))[:3]
    print(f"y={y:3d}: RGB=({r:3d}, {g:3d}, {b:3d})")

# Let's inspect the offerings specifically: where are the candles and bowls?
# Totem center is around x=483. Offerings width is ~64px, so x=450..520
print("\n--- Offerings scan (x=450..520, y=260..350) ---")
max_offering_y = -1
for y in range(250, 350):
    for x in range(450, 520):
        r, g, b = pixel_sel.getpixel((x, y))[:3]
        # Look for offerings colors: bone cream flowers, gold candle flames, terracotta bowls
        # If r > 60 or g > 60 or b > 60, not dark ground/shadow
        if (r > 100 and g > 80) or (r > 80 and g > 50 and b < 50): # gold flame or warm offerings
            if y > max_offering_y:
                max_offering_y = y

print(f"Lowest bright offering pixel y: {max_offering_y}, Margin to 360: {360 - max_offering_y}px")
