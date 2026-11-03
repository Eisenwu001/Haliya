import os
from PIL import Image

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"
b = Image.open(os.path.join(artifact_dir, "before_continue_selected.png"))

print("before_continue_selected size:", b.size)
# Sample points across the image
print("Sky right (480, 80):", b.getpixel((480 * b.width // 640, 80 * b.height // 360)))
print("Center trees (320, 180):", b.getpixel((320 * b.width // 640, 180 * b.height // 360)))
print("Lower center (320, 280):", b.getpixel((320 * b.width // 640, 280 * b.height // 360)))
print("Totem (483, 200):", b.getpixel((483 * b.width // 640, 200 * b.height // 360)))
print("Lower left (100, 280):", b.getpixel((100 * b.width // 640, 280 * b.height // 360)))
