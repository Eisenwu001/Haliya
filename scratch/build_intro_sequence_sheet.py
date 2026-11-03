import os
from PIL import Image, ImageDraw, ImageFont

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"

stages = [
    ("stage1_pixel.png", "1. STUDIO LOGO (Log's Production)"),
    ("stage2_pixel.png", "2. STUDIO CARD (GROUP 2 PRESENTS)"),
    ("stage3_pixel.png", "3. MOON PHASE LOADER (Awakening the seven moons...)"),
    ("stage4_pixel.png", "4. TITLE SCREEN (Press Any Key to Start)"),
    ("stage5_pixel.png", "5. MAIN MENU (Full Restored Design)"),
]

# Create a clean multi-slide presentation image
w, h = 640, 360
sheet_w = w * 2 + 30
sheet_h = h * 3 + 80
sheet = Image.new("RGB", (sheet_w, sheet_h), (16, 20, 18))
draw = ImageDraw.Draw(sheet)

positions = [
    (10, 30),
    (w + 20, 30),
    (10, h + 60),
    (w + 20, h + 60),
    ((sheet_w - w) // 2, 2 * h + 70),
]

for idx, (fn, title) in enumerate(stages):
    fp = os.path.join(artifact_dir, fn)
    if os.path.exists(fp):
        img = Image.open(fp)
        pos = positions[idx]
        sheet.paste(img, pos)
        draw.text((pos[0] + 4, pos[1] - 18), title, fill=(216, 207, 168))

out_path = os.path.join(artifact_dir, "intro_sequence_pipeline.png")
sheet.save(out_path)
print("Saved intro_sequence_pipeline.png")
