import os
from PIL import Image

ARTIFACT_DIR = r"C:\Users\Lin\.gemini\antigravity\brain\b7e90845-ca12-439f-9bfd-ca181b043a07"
os.makedirs(ARTIFACT_DIR, exist_ok=True)

shots = [
    ("idle", "haliya_cloth_ingame_idle.png"),
    ("walk", "haliya_cloth_ingame_walk.png"),
    ("crouch", "haliya_cloth_ingame_crouch.png")
]

for name, fn in shots:
    if not os.path.exists(fn):
        print(f"Missing {fn}")
        continue
    img = Image.open(fn)
    print(f"{name} raw size: {img.size}")
    
    # 1. Base resolution 640x360
    base_640 = img.resize((640, 360), Image.Resampling.NEAREST)
    base_out = os.path.join(ARTIFACT_DIR, f"haliya_cloth_{name}_640x360.png")
    base_640.save(base_out)
    print(f"Saved {base_out}")
    
    # 2. Find player crop in 640x360
    # In Forest 1-1, player spawn is roughly x=180..260, y=200..320
    # Let's crop 120x120 around player (x=160..280, y=190..310)
    crop_1x = base_640.crop((160, 190, 280, 310))
    crop_1x_out = os.path.join(ARTIFACT_DIR, f"haliya_cloth_{name}_crop_1x.png")
    crop_1x.save(crop_1x_out)
    
    # 3. 3x pixel art zoom
    crop_3x = crop_1x.resize((crop_1x.width * 3, crop_1x.height * 3), Image.Resampling.NEAREST)
    crop_3x_out = os.path.join(ARTIFACT_DIR, f"haliya_cloth_{name}_crop_3x.png")
    crop_3x.save(crop_3x_out)
    print(f"Saved {crop_3x_out} (size {crop_3x.size})")

print("Processing complete!")
