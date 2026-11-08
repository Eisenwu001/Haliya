import os
from PIL import Image

ARTIFACT_DIR = r"C:\Users\Lin\.gemini\antigravity\brain\b7e90845-ca12-439f-9bfd-ca181b043a07"

shots = [
    ("idle", "haliya_cloth_ingame_idle.png"),
    ("walk", "haliya_cloth_ingame_walk.png"),
    ("crouch", "haliya_cloth_ingame_crouch.png")
]

# Exact player bounding box in 640x360:
# x: 130..250 (120px wide)
# y: 145..285 (140px tall)
crop_box = (130, 145, 250, 285)

crops_3x = []

for name, fn in shots:
    raw_img = Image.open(fn)
    # 640x360 base resolution
    base_640 = raw_img.resize((640, 360), Image.Resampling.NEAREST)
    base_path = os.path.join(ARTIFACT_DIR, f"haliya_cloth_{name}_fullscreen_640x360.png")
    base_640.save(base_path)
    
    # 1x crop
    p_crop = base_640.crop(crop_box)
    crop_1x_path = os.path.join(ARTIFACT_DIR, f"haliya_cloth_{name}_crop_1x.png")
    p_crop.save(crop_1x_path)
    
    # 3x pixel art zoom
    crop_3x = p_crop.resize((p_crop.width * 3, p_crop.height * 3), Image.Resampling.NEAREST)
    crop_3x_path = os.path.join(ARTIFACT_DIR, f"haliya_cloth_{name}_crop_3x.png")
    crop_3x.save(crop_3x_path)
    crops_3x.append((name, crop_3x))
    print(f"Saved {name}: 1x ({p_crop.size}) and 3x ({crop_3x.size})")

# Also create a composite 3-panel showcase: Idle | Walk | Crouch at 3x
w, h = crops_3x[0][1].size
showcase = Image.new('RGBA', (w * len(crops_3x) + 20 * (len(crops_3x) - 1), h + 40), (16, 20, 24, 255))
from PIL import ImageDraw
draw = ImageDraw.Draw(showcase)

for i, (name, crp) in enumerate(crops_3x):
    x_pos = i * (w + 20)
    showcase.paste(crp, (x_pos, 35))
    draw.text((x_pos + 10, 10), f"Haliya {name.capitalize()} (3x Scale)", fill=(216, 207, 168, 255))

showcase_path = os.path.join(ARTIFACT_DIR, "haliya_cloth_showcase_3x.png")
showcase.save(showcase_path)
print(f"Saved showcase: {showcase_path}")
