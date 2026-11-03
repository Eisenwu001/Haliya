import os
from PIL import Image

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"
pixel_sel = Image.open(os.path.join(artifact_dir, "pass4_full_menu_pixel.png"))

# Let's crop around the totem base and offerings: x=440..530, y=240..340
crop = pixel_sel.crop((440, 240, 530, 340))
crop.save(os.path.join(artifact_dir, "pass4_offerings_region.png"))

# Let's check offerings.png original size
off_img = Image.open(r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\art\offerings.png")
print("offerings.png size:", off_img.size)

# Find rows in pixel_sel that contain offerings pixels (flowers are #d8cfa8, flame is #c9a24a)
# Flowers: (216, 207, 168) or similar
print("Searching for flower and lamp pixels in x=450..520, y=250..340:")
for y in range(250, 340):
    flower_px = []
    for x in range(450, 520):
        r, g, b = pixel_sel.getpixel((x, y))[:3]
        if (r > 180 and g > 170 and b > 140): # flower bone cream
            flower_px.append(x)
    if flower_px:
        print(f"y={y}: flower pixels at x={min(flower_px)}..{max(flower_px)}")
