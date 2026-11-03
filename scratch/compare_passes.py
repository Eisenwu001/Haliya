import os
from PIL import Image

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"
p2 = Image.open(os.path.join(artifact_dir, "after_continue_selected.png")).resize((640, 360), Image.Resampling.NEAREST)
p3 = Image.open(os.path.join(artifact_dir, "pass3_full_menu_pixel.png"))
p4 = Image.open(os.path.join(artifact_dir, "pass4_full_menu.png"))

print("P2 center (320, 180):", p2.getpixel((320, 180)))
print("P3 center (320, 180):", p3.getpixel((320, 180)))
print("P4 center (320, 180):", p4.getpixel((320, 180)))

print("P2 sky right (480, 80):", p2.getpixel((480, 80)))
print("P3 sky right (480, 80):", p3.getpixel((480, 80)))
print("P4 sky right (480, 80):", p4.getpixel((480, 80)))

print("P2 totem (483, 200):", p2.getpixel((483, 200)))
print("P3 totem (483, 200):", p3.getpixel((483, 200)))
print("P4 totem (483, 200):", p4.getpixel((483, 200)))
