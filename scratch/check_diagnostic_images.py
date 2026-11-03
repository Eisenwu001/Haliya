import os
from PIL import Image

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"
for t in ["0.2s", "0.5s", "1.0s", "2.0s", "4.0s", "6.0s", "8.0s", "10.0s"]:
    fn = f"diagnostic_time_{t}.png"
    p = os.path.join(artifact_dir, fn)
    if os.path.exists(p):
        img = Image.open(p)
        colors = set(img.getpixel((x, y))[:3] for y in range(0, img.height, 10) for x in range(0, img.width, 10))
        print(f"{fn}: size={img.size}, unique sampled colors={len(colors)}, colors sample={list(colors)[:5]}")
