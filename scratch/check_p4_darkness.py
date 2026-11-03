import os
from PIL import Image

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"
p4 = Image.open(os.path.join(artifact_dir, "pass4_full_menu.png"))

print("pass4_full_menu size:", p4.size)
# Sample across the image:
# Sky region: (480, 40)
print("Moon/sky region (480, 40):", p4.getpixel((480, 40)))
# Sky left: (200, 30)
print("Sky left (200, 30):", p4.getpixel((200, 30)))
# Center trees (320, 180):
print("Center (320, 180):", p4.getpixel((320, 180)))
# Lower left (100, 280):
print("Lower left (100, 280):", p4.getpixel((100, 280)))
# Totem (480, 180):
print("Totem (480, 180):", p4.getpixel((480, 180)))

# Let's count how many pixels have RGB sum < 40 (near pitch black)
total_px = p4.width * p4.height
dark_px = sum(1 for y in range(p4.height) for x in range(p4.width) if sum(p4.getpixel((x, y))[:3]) < 45)
print(f"Percentage of near-black pixels: {dark_px / total_px * 100:.1f}%")
