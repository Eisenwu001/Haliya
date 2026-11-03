import os
from PIL import Image

artifact_dir = r"C:\Users\Lin\.gemini\antigravity\brain\370c75b3-591d-4ff9-a2ef-a82753b68d30"
pixel_sel = Image.open(os.path.join(artifact_dir, "pass4_full_menu_pixel.png"))

def lum(c):
    s = [v / 255.0 for v in c]
    s = [((v + 0.055) / 1.055) ** 2.4 if v > 0.04045 else v / 12.92 for v in s]
    return 0.2126 * s[0] + 0.7152 * s[1] + 0.0722 * s[2]

def get_contrast(fg_rgb, bg_rgb):
    l1 = lum(fg_rgb)
    l2 = lum(bg_rgb)
    lighter = max(l1, l2)
    darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)

# Scan title region x=28..150, y=48..85 for bright pixels
bright_title_px = []
for y in range(45, 85):
    for x in range(25, 150):
        p = pixel_sel.getpixel((x, y))[:3]
        if p[0] > 140 and p[1] > 130:
            bright_title_px.append((x, y, p))

if bright_title_px:
    sample = bright_title_px[len(bright_title_px)//2]
    bg_p = pixel_sel.getpixel((15, sample[1]))[:3]
    print(f"Title bright pixel at ({sample[0]}, {sample[1]}): {sample[2]}, BG at (15, {sample[1]}): {bg_p}")
    print(f"Title contrast ratio: {get_contrast(sample[2], bg_p):.2f}:1")
