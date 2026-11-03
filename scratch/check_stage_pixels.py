import os
from PIL import Image

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"

for s in [1, 2, 3, 4, 5]:
    img = Image.open(os.path.join(artifact_dir, f"stage{s}_pixel.png"))
    # count non-black pixels (sum > 60)
    bright = sum(1 for y in range(img.height) for x in range(img.width) if sum(img.getpixel((x, y))[:3]) > 60)
    print(f"Stage {s}: bright pixel count = {bright}")
