import os
from PIL import Image

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"

for s in [1, 2, 3, 4, 5]:
    files = [f for f in os.listdir(artifact_dir) if f.startswith(f"stage{s}_")]
    if files:
        fn = files[0]
        img = Image.open(os.path.join(artifact_dir, fn))
        print(f"Stage {s} ({fn}): size={img.size}")
        # Downsample to 640x360 with nearest neighbor and save
        down = img.resize((640, 360), Image.Resampling.NEAREST)
        down.save(os.path.join(artifact_dir, f"stage{s}_pixel.png"))
