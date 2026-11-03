import os
from PIL import Image, ImageDraw, ImageFont

# Screen dimensions 1280x720
w, h = 1280, 720
img = Image.new("RGBA", (w, h), (3, 2, 4, 255))
draw = ImageDraw.Draw(img)

# Load a sample comic image as background in 16:9
comic_path = "Haliya Story/Haliya comic scene.png"
if os.path.exists(comic_path):
    comic = Image.open(comic_path).convert("RGBA")
    # Resize to fit within letterbox (e.g. 1152x648)
    comic_resized = comic.resize((1152, 648), Image.Resampling.LANCZOS)
    img.paste(comic_resized, ((w - 1152) // 2, (h - 648) // 2))

# Darken with soft vignette
vignette = Image.new("RGBA", (w, h), (0, 0, 0, 0))
v_draw = ImageDraw.Draw(vignette)
for r in range(120):
    alpha = int((r / 120.0) ** 2 * 180)
    v_draw.rectangle([r, r, w - r, h - r], outline=(0, 0, 0, 4))
img = Image.alpha_composite(img, vignette)
draw = ImageDraw.Draw(img)

# 1. Cinema Top Bar (Height 52px)
draw.rectangle([0, 0, w, 52], fill=(4, 3, 5, 255))
draw.line([(0, 52), (w, 52)], fill=(200, 168, 72, 120), width=1)

# 2. Cinema Bottom Bar (Height 64px)
draw.rectangle([0, h - 64, w, h], fill=(4, 3, 5, 255))
draw.line([(0, h - 64), (w, h - 64)], fill=(200, 168, 72, 120), width=1)

try:
    font_gold = ImageFont.truetype("alagard.ttf", 20)
    font_sub = ImageFont.truetype("alagard.ttf", 15)
    font_roman = ImageFont.truetype("alagard.ttf", 15)
except Exception:
    font_gold = ImageFont.load_default()
    font_sub = ImageFont.load_default()
    font_roman = ImageFont.load_default()

# Bottom Subtitle Prompt
draw.text((w // 2, h - 34), "Press Space or Click to continue  •  [ESC] Skip", fill=(230, 222, 210, 220), font=font_sub, anchor="mm")
draw.text((w - 50, h - 34), "[ 1 / 9 ]", fill=(200, 175, 110, 220), font=font_roman, anchor="rm")

# Add some soft glowing motes
import random
random.seed(42)
for _ in range(35):
    mx = random.randint(40, w - 40)
    my = random.randint(60, h - 70)
    rad = random.uniform(1.0, 2.5)
    draw.ellipse([mx - rad, my - rad, mx + rad, my + rad], fill=(245, 225, 150, random.randint(70, 180)))

out_path = "C:/Users/Lin/.gemini/antigravity/brain/6fd12419-defb-4ac8-a90b-58865f9d5a8a/cinematic_cutscene_widescreen_preview.png"
img.save(out_path)
print("Saved widescreen preview to:", out_path)
