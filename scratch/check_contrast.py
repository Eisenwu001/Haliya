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

# Text of CONTINUE at x=35, y=130
fg_text = pixel_sel.getpixel((35, 130))[:3]
# Background right next to text at x=34, y=130
bg_text = pixel_sel.getpixel((34, 130))[:3]
# Background panel behind menu column at x=15, y=130
bg_panel = pixel_sel.getpixel((15, 130))[:3]

print(f"CONTINUE text color at (35, 130): RGB={fg_text}")
print(f"Background at (15, 130): RGB={bg_panel}")
print(f"Contrast Ratio: {get_contrast(fg_text, bg_panel):.2f}:1")

# Caption text at x=35, y=147
fg_cap = pixel_sel.getpixel((35, 147))[:3]
print(f"Caption text color at (35, 147): RGB={fg_cap}")
print(f"Caption Contrast Ratio: {get_contrast(fg_cap, bg_panel):.2f}:1")

# Title text at x=40, y=60
fg_title = pixel_sel.getpixel((40, 60))[:3]
bg_title = pixel_sel.getpixel((15, 60))[:3]
print(f"Title text color: RGB={fg_title}, BG: RGB={bg_title}")
print(f"Title Contrast Ratio: {get_contrast(fg_title, bg_title):.2f}:1")
