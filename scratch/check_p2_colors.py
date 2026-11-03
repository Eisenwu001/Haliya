import os
from PIL import Image

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"
p2 = Image.open(os.path.join(artifact_dir, "after_continue_selected.png"))

print("after_continue_selected size:", p2.size)
print("Sky left (200, 30):", p2.getpixel((200, 30)))
print("Center (320, 180):", p2.getpixel((320, 180)))
print("Lower left (100, 280):", p2.getpixel((100, 280)))
print("Totem (480, 180):", p2.getpixel((480, 180)))
