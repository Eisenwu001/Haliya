import os
from PIL import Image

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"

names = [
    (1, "stage1_logs_production.png"),
    (2, "stage2_group2_presents.png"),
    (3, "stage3_moon_phase_loading.png"),
    (4, "stage4_press_any_key.png"),
    (5, "stage5_restored_main_menu.png"),
]

for s, fn in names:
    fp = os.path.join(artifact_dir, fn)
    if os.path.exists(fp):
        img = Image.open(fp)
        down = img.resize((640, 360), Image.Resampling.NEAREST)
        out_fn = f"stage{s}_pixel.png"
        down.save(os.path.join(artifact_dir, out_fn))
        bright = sum(1 for y in range(down.height) for x in range(down.width) if sum(down.getpixel((x, y))[:3]) > 60)
        print(f"Stage {s} ({fn}): size={img.size}, bright pixels={bright}")
